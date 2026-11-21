{ stableLib, kernelPackages, ... }:

let
    asus-screenpad-backlight = kernelPackages.callPackage ./screenpad-backlight { };
in

{
    boot = {
        zswap = {
            enable = true;
            maxPoolPercent = 20;
        };

        extraModulePackages = with kernelPackages; [ turbostat asus-screenpad-backlight ];
        kernelModules = [ "asus-screenpad-backlight" ];

        initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

        extraModprobeConfig = ''
            options asus_wmi fnlock_default=0
        '';

        blacklistedKernelModules = [ "nouveau" ];
    };

    hardware.enableRedistributableFirmware = stableLib.mkDefault true;
}
