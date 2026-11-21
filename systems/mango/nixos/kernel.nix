{ stableLib, kernelPackages, ... }:

{
    boot = {
        zswap = {
            enable = true;
            maxPoolPercent = 20;
        };

        extraModulePackages = with kernelPackages; [ turbostat ];
        initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

        kernelModules = [ "iwlwifi" ]; # sometimes doesn't get autoloaded
        blacklistedKernelModules = [ "rtw88_8821ce" ]; # this adapter is hopelessly broken :/
    };

    hardware.enableRedistributableFirmware = stableLib.mkDefault true;
}
