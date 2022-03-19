{ lib, kernelPackages, ... }:

{
    boot.extraModulePackages = with kernelPackages; [ turbostat asus-wmi-sensors ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

    boot.extraModprobeConfig = ''
        options asus_wmi fnlock_default=0
    '';

    hardware.enableRedistributableFirmware = lib.mkDefault true;
}
