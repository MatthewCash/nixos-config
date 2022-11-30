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

    fileSystems = {
        root = {
            device = "tmpfs-root";
            fsType = "tmpfs";
            mountPoint = "/";
            options = [ "defaults" "size=4G" "mode=755" ];
        };
        nix = {
            label = "nix";
            fsType = "btrfs";
            mountPoint = "/nix";
            options = [ "rw" "noatime" ];

            # Needed to decrypt agenix secrets
            neededForBoot = true;
        };

        boot = {
            label = "efi";
            fsType = "vfat";
            mountPoint = "/boot";
            options = [ "nofail" ];
        };
    };
}
