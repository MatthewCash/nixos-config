{ stableLib, kernelPackages, ... }:

let
    asus-screenpad-backlight = kernelPackages.callPackage ./screenpad-backlight { };
in

{
    boot.extraModulePackages = with kernelPackages; [ turbostat asus-screenpad-backlight ];
    boot.kernelModules = [ "asus-screenpad-backlight" ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

    boot.extraModprobeConfig = ''
        options asus_wmi fnlock_default=0
    '';

    hardware.enableRedistributableFirmware = stableLib.mkDefault true;

    boot.blacklistedKernelModules = [ "nouveau" ];
}
