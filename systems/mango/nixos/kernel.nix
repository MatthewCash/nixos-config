{ stableLib, kernelPackages, ... }:

{
    boot.extraModulePackages = with kernelPackages; [ turbostat ];
    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

    hardware.enableRedistributableFirmware = stableLib.mkDefault true;

    boot.kernelModules = [ "iwlwifi" ]; # sometimes doesn't get autoloaded
    boot.blacklistedKernelModules = [ "rtw88_8821ce" ]; # this adapter is hopelessly broken :/
}
