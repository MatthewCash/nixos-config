{ ... }:

let
    storageBindMountOptions = [ "bind" "nofail" ];
in

{
    boot.initrd.availableKernelModules = [ "cryptd" ];

    boot.initrd.luks.devices = {
        crypt-nix.device = "/dev/disk/by-label/crypt-nix";
    };

    services.samba.enable = true;

    fileSystems = {
        storage = {
            label = "storage";
            fsType = "btrfs";
            mountPoint = "/mnt/storage";
            options = [ "rw" "noatime" "ssd" "space_cache" "nofail" ];
        };

        # Storage Bind Mounts

        code = {
            device = "/mnt/storage/code";
            mountPoint = "/home/matthew/code";
            options = storageBindMountOptions;
        };

        documents = {
            device = "/mnt/storage/Documents";
            mountPoint = "/home/matthew/documents";
            options = storageBindMountOptions;
        };

        downloads = {
            device = "/mnt/storage/Downloads";
            mountPoint = "/home/matthew/downloads";
            options = storageBindMountOptions;
        };

        games = {
            device = "/mnt/storage/games";
            mountPoint = "/home/matthew/games";
            options = storageBindMountOptions;
        };

        music = {
            device = "/mnt/storage/Music";
            mountPoint = "/home/matthew/music";
            options = storageBindMountOptions;
        };

        pictures = {
            device = "/mnt/storage/Pictures";
            mountPoint = "/home/matthew/pictures";
            options = storageBindMountOptions;
        };

        videos = {
            device = "/mnt/storage/Videos";
            mountPoint = "/home/matthew/videos";
            options = storageBindMountOptions;
        };
    };
}
