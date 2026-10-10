// SPDX-License-Identifier: GPL-2.0

#include <linux/acpi.h>
#include <linux/backlight.h>
#include <linux/device.h>
#include <linux/kernel.h>
#include <linux/math.h>
#include <linux/module.h>
#include <linux/pci.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/wmi.h>
#include <linux/workqueue.h>

#define ASUS_WMI_MGMT_GUID "97845ED0-4E6D-11DE-8A39-0800200C9A66"
#define ASUS_WMI_METHODID_DEVS 0x53564544 /* DEVice Set */
#define ASUS_WMI_UNSUPPORTED_METHOD 0xFFFFFFFE
#define ASUS_WMI_DEVID_SCREENPAD_POWER 0x00050031
#define ASUS_WMI_DEVID_SCREENPAD_LIGHT 0x00050032

#define SCREENPAD_GPU_DOMAIN 0
#define SCREENPAD_GPU_BUS 0
#define SCREENPAD_GPU_SLOT 2
#define SCREENPAD_GPU_FUNCTION 0
#define SCREENPAD_SOURCE_BACKLIGHT "asus_screenpad"
#define SCREENPAD_INITIAL_BACKLIGHT "intel_backlight"
#define SCREENPAD_CONNECTOR "HDMI-A-2"
#define SCREENPAD_CONNECTOR_ALIAS "HDMI-2"
#define SCREENPAD_PROXY_BACKLIGHT "asus_screenpad_connector"

struct bios_args {
	u32 arg0;
	u32 arg1;
	u32 arg2;
	u32 arg3;
	u32 arg4;
	u32 arg5;
} __packed;

struct screenpad_proxy {
	struct device *device;
	struct device *connector;
	struct device *connector_alias;
	struct backlight_device *source;
	struct backlight_device *backlight;
	struct workqueue_struct *workqueue;
};

struct brightness_request {
	struct work_struct work;
	struct screenpad_proxy *proxy;
	unsigned int brightness;
};

struct connector_search {
	const char *suffix;
	struct device *connector;
};

static int screenpad_wmi_set(u32 dev_id, u32 ctrl_param)
{
	struct bios_args args = {
		.arg0 = dev_id,
		.arg1 = ctrl_param,
		.arg2 = 0,
	};
	struct acpi_buffer input = { (acpi_size)sizeof(args), &args };
	struct acpi_buffer output = { ACPI_ALLOCATE_BUFFER, NULL };
	union acpi_object *obj;
	acpi_status status;
	u32 result = 0;

	status = wmi_evaluate_method(ASUS_WMI_MGMT_GUID, 0,
				     ASUS_WMI_METHODID_DEVS, &input, &output);
	if (ACPI_FAILURE(status))
		return -EIO;

	obj = output.pointer;
	if (obj && obj->type == ACPI_TYPE_INTEGER)
		result = (u32)obj->integer.value;
	kfree(obj);

	return result == ASUS_WMI_UNSUPPORTED_METHOD ? -ENODEV : 0;
}

static int screenpad_set_brightness(struct screenpad_proxy *proxy,
				    unsigned int brightness)
{
	int ret;

	if (brightness) {
		ret = screenpad_wmi_set(ASUS_WMI_DEVID_SCREENPAD_POWER, 1);
		if (!ret)
			ret = screenpad_wmi_set(ASUS_WMI_DEVID_SCREENPAD_LIGHT,
						brightness);
	} else {
		ret = screenpad_wmi_set(ASUS_WMI_DEVID_SCREENPAD_POWER, 0);
	}
	if (ret)
		return ret;

	/* Avoid the upstream callback's reversed BACKLIGHT_POWER semantics. */
	WRITE_ONCE(proxy->source->props.brightness, brightness);
	WRITE_ONCE(proxy->source->props.power,
		   brightness ? BACKLIGHT_POWER_ON : BACKLIGHT_POWER_OFF);

	return 0;
}

static int find_connector(struct device *dev, void *data)
{
	struct connector_search *search = data;
	const char *name = dev_name(dev);
	size_t name_len = name ? strlen(name) : 0;
	size_t suffix_len = strlen(search->suffix);

	if (dev->type && dev->type->name &&
	    !strcmp(dev->type->name, "drm_connector") &&
	    name_len >= suffix_len &&
	    !strcmp(name + name_len - suffix_len, search->suffix)) {
		search->connector = get_device(dev);
		return 1;
	}

	return device_for_each_child(dev, search, find_connector);
}

static struct device *get_screenpad_connector(void)
{
	struct connector_search search = {
		.suffix = "-" SCREENPAD_CONNECTOR,
	};
	struct pci_dev *gpu;

	gpu = pci_get_domain_bus_and_slot(SCREENPAD_GPU_DOMAIN,
					  SCREENPAD_GPU_BUS,
					  PCI_DEVFN(SCREENPAD_GPU_SLOT,
						    SCREENPAD_GPU_FUNCTION));
	if (!gpu)
		return ERR_PTR(-EPROBE_DEFER);

	device_for_each_child(&gpu->dev, &search, find_connector);
	pci_dev_put(gpu);

	return search.connector ?: ERR_PTR(-EPROBE_DEFER);
}

static ssize_t enabled_show(struct device *dev,
			    struct device_attribute *attr, char *buf)
{
	return sysfs_emit(buf, "enabled\n");
}
static DEVICE_ATTR_RO(enabled);

static struct attribute *connector_alias_attrs[] = {
	&dev_attr_enabled.attr,
	NULL,
};

static const struct attribute_group connector_alias_group = {
	.attrs = connector_alias_attrs,
};

static const struct attribute_group *connector_alias_groups[] = {
	&connector_alias_group,
	NULL,
};

static const struct device_type connector_alias_type = {
	.name = "drm_connector",
};

static void connector_alias_release(struct device *dev)
{
	kfree(dev);
}

static struct device *create_connector_alias(struct device *connector)
{
	struct device *alias;
	int ret;

	alias = kzalloc(sizeof(*alias), GFP_KERNEL);
	if (!alias)
		return ERR_PTR(-ENOMEM);

	device_initialize(alias);
	alias->class = connector->class;
	alias->type = &connector_alias_type;
	alias->parent = connector->parent;
	alias->groups = connector_alias_groups;
	alias->release = connector_alias_release;

	ret = dev_set_name(alias, "%s-proxy-%s", dev_name(connector->parent),
			   SCREENPAD_CONNECTOR_ALIAS);
	if (ret)
		goto err_put;

	ret = device_add(alias);
	if (ret)
		goto err_put;

	return alias;

err_put:
	put_device(alias);
	return ERR_PTR(ret);
}

static void set_screenpad_brightness(struct work_struct *work)
{
	struct brightness_request *request =
		container_of(work, struct brightness_request, work);
	int ret;

	ret = screenpad_set_brightness(request->proxy, request->brightness);
	if (ret)
		dev_warn_ratelimited(request->proxy->device,
				     "Failed to set ScreenPad brightness: %d\n",
				     ret);

	kfree(request);
}

static int screenpad_proxy_update_status(struct backlight_device *backlight)
{
	struct screenpad_proxy *proxy = bl_get_data(backlight);
	struct brightness_request *request;

	request = kmalloc(sizeof(*request), GFP_KERNEL);
	if (!request)
		return -ENOMEM;

	request->proxy = proxy;
	request->brightness = backlight_get_brightness(backlight);
	INIT_WORK(&request->work, set_screenpad_brightness);
	queue_work(proxy->workqueue, &request->work);

	return 0;
}

static bool screenpad_proxy_controls_device(struct backlight_device *backlight,
					    struct device *display)
{
	struct screenpad_proxy *proxy = bl_get_data(backlight);

	return !display || display == proxy->connector;
}

static const struct backlight_ops screenpad_proxy_ops = {
	.update_status = screenpad_proxy_update_status,
	.controls_device = screenpad_proxy_controls_device,
};

static void screenpad_proxy_destroy(struct screenpad_proxy *proxy)
{
	if (proxy->backlight)
		backlight_device_unregister(proxy->backlight);
	if (proxy->workqueue)
		destroy_workqueue(proxy->workqueue);
	if (proxy->connector_alias)
		device_unregister(proxy->connector_alias);
	if (proxy->connector)
		put_device(proxy->connector);
	if (proxy->source)
		put_device(&proxy->source->dev);
}

static int screenpad_proxy_create(struct platform_device *pdev,
				  struct screenpad_proxy *proxy)
{
	struct backlight_properties props = {};
	struct backlight_device *initial;
	unsigned int initial_brightness;
	unsigned int initial_max;
	unsigned int source_max;
	int ret;

	proxy->device = &pdev->dev;
	proxy->source = backlight_device_get_by_name(SCREENPAD_SOURCE_BACKLIGHT);
	if (!proxy->source)
		return dev_err_probe(&pdev->dev, -EPROBE_DEFER,
				     "Waiting for backlight %s\n",
				     SCREENPAD_SOURCE_BACKLIGHT);

	initial = backlight_device_get_by_name(SCREENPAD_INITIAL_BACKLIGHT);
	if (!initial) {
		ret = dev_err_probe(&pdev->dev, -EPROBE_DEFER,
				    "Waiting for initial backlight %s\n",
				    SCREENPAD_INITIAL_BACKLIGHT);
		goto err_destroy;
	}

	initial_max = READ_ONCE(initial->props.max_brightness);
	source_max = READ_ONCE(proxy->source->props.max_brightness);
	if (!initial_max || !source_max) {
		put_device(&initial->dev);
		ret = dev_err_probe(&pdev->dev, -EINVAL,
				    "Backlight maximum brightness is zero\n");
		goto err_destroy;
	}

	initial_brightness = DIV_ROUND_CLOSEST_ULL(
		(u64)backlight_get_brightness(initial) * source_max,
		initial_max);
	put_device(&initial->dev);

	ret = screenpad_wmi_set(ASUS_WMI_DEVID_SCREENPAD_POWER, 1);
	if (ret)
		dev_info(&pdev->dev, "ScreenPad power-on not available: %d\n",
			 ret);
	else
		dev_info(&pdev->dev, "ScreenPad panel powered on\n");

	proxy->connector = get_screenpad_connector();
	if (IS_ERR(proxy->connector)) {
		ret = PTR_ERR(proxy->connector);
		proxy->connector = NULL;
		ret = dev_err_probe(&pdev->dev, ret,
				    "Waiting for DRM connector %s\n",
				    SCREENPAD_CONNECTOR);
		goto err_destroy;
	}

	proxy->connector_alias = create_connector_alias(proxy->connector);
	if (IS_ERR(proxy->connector_alias)) {
		ret = PTR_ERR(proxy->connector_alias);
		proxy->connector_alias = NULL;
		goto err_destroy;
	}

	proxy->workqueue = alloc_ordered_workqueue("screenpad-backlight",
						   WQ_MEM_RECLAIM);
	if (!proxy->workqueue) {
		ret = -ENOMEM;
		goto err_destroy;
	}

	props.type = BACKLIGHT_RAW;
	props.max_brightness = source_max;
	props.brightness = initial_brightness;
	props.power = BACKLIGHT_POWER_ON;
	props.scale = READ_ONCE(proxy->source->props.scale);

	ret = screenpad_set_brightness(proxy, initial_brightness);
	if (ret) {
		dev_err(&pdev->dev,
			"Failed to set initial ScreenPad brightness: %d\n", ret);
		goto err_destroy;
	}

	proxy->backlight = backlight_device_register(
		SCREENPAD_PROXY_BACKLIGHT, proxy->connector_alias, proxy,
		&screenpad_proxy_ops, &props);
	if (IS_ERR(proxy->backlight)) {
		ret = PTR_ERR(proxy->backlight);
		proxy->backlight = NULL;
		goto err_destroy;
	}

	dev_info(&pdev->dev,
		 "Proxied %s to DRM connector %s as %s at brightness %u\n",
		 SCREENPAD_SOURCE_BACKLIGHT, SCREENPAD_CONNECTOR,
		 SCREENPAD_CONNECTOR_ALIAS, initial_brightness);

	return 0;

err_destroy:
	screenpad_proxy_destroy(proxy);
	return ret;
}

static int screenpad_proxy_probe(struct platform_device *pdev)
{
	struct screenpad_proxy *proxy;
	int ret;

	proxy = devm_kzalloc(&pdev->dev, sizeof(*proxy), GFP_KERNEL);
	if (!proxy)
		return -ENOMEM;

	ret = screenpad_proxy_create(pdev, proxy);
	if (ret)
		return ret;

	platform_set_drvdata(pdev, proxy);
	return 0;
}

static void screenpad_proxy_remove(struct platform_device *pdev)
{
	screenpad_proxy_destroy(platform_get_drvdata(pdev));
}

static int screenpad_proxy_resume(struct device *dev)
{
	struct screenpad_proxy *proxy = dev_get_drvdata(dev);

	return screenpad_set_brightness(
		proxy, backlight_get_brightness(proxy->backlight));
}

static DEFINE_SIMPLE_DEV_PM_OPS(screenpad_proxy_pm_ops, NULL,
				screenpad_proxy_resume);

static struct platform_driver screenpad_proxy_driver = {
	.driver = {
		.name = "asus-screenpad-backlight",
		.pm = pm_sleep_ptr(&screenpad_proxy_pm_ops),
	},
	.probe = screenpad_proxy_probe,
	.remove = screenpad_proxy_remove,
};

static struct platform_device *screenpad_proxy_device;

static int __init screenpad_proxy_init(void)
{
	int ret;

	ret = platform_driver_register(&screenpad_proxy_driver);
	if (ret)
		return ret;

	screenpad_proxy_device = platform_device_register_simple(
		"asus-screenpad-backlight", PLATFORM_DEVID_NONE, NULL, 0);
	if (IS_ERR(screenpad_proxy_device)) {
		ret = PTR_ERR(screenpad_proxy_device);
		platform_driver_unregister(&screenpad_proxy_driver);
		return ret;
	}

	return 0;
}

static void __exit screenpad_proxy_exit(void)
{
	platform_device_unregister(screenpad_proxy_device);
	platform_driver_unregister(&screenpad_proxy_driver);
}

MODULE_AUTHOR("Matthew");
MODULE_DESCRIPTION("ASUS ScreenPad DRM connector backlight proxy");
MODULE_LICENSE("GPL");
MODULE_VERSION("8");
MODULE_SOFTDEP("pre: asus_wmi i915");

module_init(screenpad_proxy_init);
module_exit(screenpad_proxy_exit);
