{ ... }:

{
    boot.initrd.availableKernelModules = [ "cryptd" ];

    boot.initrd.luks.devices = {
        lvm = {
            device = "/dev/disk/by-label/crypt-main";
            bypassWorkqueues = true;
        };
    };

    swapDevices = [
        {
            device = "/dev/main/swap";
            randomEncryption.enable = true;
        }
    ];
}
