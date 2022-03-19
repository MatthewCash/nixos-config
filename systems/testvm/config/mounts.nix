{ ... }:

{
    boot.initrd.availableKernelModules = [ "cryptd" ];

    boot.initrd.luks.devices = {
        crypt-nix.device = "/dev/disk/by-label/crypt-nix";
    };
}
