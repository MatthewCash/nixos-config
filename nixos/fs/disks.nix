{ persistPath, ... }:

{
    environment.persistence.${persistPath} = {
        directories = [
            "/var/log"
        ];
        files = [
            "/etc/machine-id"
        ];
    };

    fileSystems."/mnt/persist".neededForBoot = true;

    disko.devices = {
        disk.main.content = {
            type = "gpt";
            partitions.efi = {
                type = "EF00";
                start = "1MiB";
                end = "2GiB";
                content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                };
            };
        };

        lvm_vg.main = { 
            type = "lvm_vg";
            lvs = {
                thin-main = {
                    size = "95%FREE";
                    lvm_type = "thin-pool";
                    extraArgs = [ "--errorwhenfull y" ];
                };
                nix = {
                    lvm_type = "thinlv";
                    pool = "thin-main";
                    content = {
                        type = "filesystem";
                        format = "btrfs";
                        mountpoint = "/nix";
                        mountOptions = [ "noatime" "compress=zstd" ];
                    };
                };
                persist = {
                    lvm_type = "thinlv";
                    pool = "thin-main";
                    content = {
                        type = "filesystem";
                        format = "btrfs";
                        mountpoint = "/mnt/persist";
                        mountOptions = [ "noatime" "compress=zstd" ];
                    };
                };
            };
        };

        nodev."tmpfs-root" = {
            mountpoint = "/";
            fsType = "tmpfs";
            mountOptions = [ "size=4G" "nr_inodes=4M" "mode=755" ];
        };
    };
}
