{ stableLib, kernelPackages, inputs, system, ... }:

let
    asus-wmi-screenpad = inputs.asus-wmi-screenpad.defaultPackage.${system}.override kernelPackages.kernel.dev;
in

{
    boot.extraModulePackages = with kernelPackages; [ turbostat asus-wmi-screenpad ];
    boot.kernelModules = [ "asus-wmi-screenpad" ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

    boot.extraModprobeConfig = ''
        options asus_wmi fnlock_default=0
    '';

    hardware.enableRedistributableFirmware = stableLib.mkDefault true;
}
