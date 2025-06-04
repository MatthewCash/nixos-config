{ persistPath, ... }:

{
    age.identityPaths = [
        "${persistPath}/etc/ssh/ssh_host_ed25519_key"
    ];

    programs.fuse.userAllowOther = true;

    environment.persistence.${persistPath} = {
        directories = [
            "/var/log"
        ];

        files = [
            "/etc/machine-id"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
    };

    fileSystems."/mnt/persist".neededForBoot = true;

    disko.devices = {
        disk.main.content = {
            type = "gpt";
            partitions.efi = {
                type = "EF00";
                start = "1MiB";
                end = "512MiB";
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
                };
                nix = {
                    lvm_type = "thinlv";
                    pool = "thin-main";
                    content = {
                        type = "filesystem";
                        format = "btrfs";
                        mountpoint = "/nix";
                        mountOptions = [ "noatime" ];
                    };
                };
                persist = {
                    lvm_type = "thinlv";
                    pool = "thin-main";
                    content = {
                        type = "filesystem";
                        format = "btrfs";
                        mountpoint = "/mnt/persist";
                        mountOptions = [ "noatime" ];
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
