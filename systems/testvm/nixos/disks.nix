{ ... }:

{
    disko.devices = {
        disk.main = {
            device = "/dev/sda";
            content.partitions.crypt-main = {
                size = "100%";
                content = {
                    type = "luks";
                    name = "crypt-main";
                    content = {
                        type = "lvm_pv";
                        vg = "main";
                    };
                    settings = {
                        bypassWorkqueues = true;
                        allowDiscards = true;
                        crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-measure-pcr=yes" ];
                    };
                };
            };
        };

        lvm_vg.main.lvs = {
            nix.size = "100G";
            persist.size = "100G";
            swap = {
                size = "30G";
                lvm_type = "thinlv";
                pool = "thin-main";
                content = {
                    type = "swap";
                    randomEncryption = true;
                };
            };
            crypt-home-matthew = {
                size = "100G";
                lvm_type = "thinlv";
                pool = "thin-main";
                content = {
                    type = "luks";
                    name = "home-matthew";
                    initrdUnlock = false; # Unlocked on login with config/pam-mount.nix
                    content = {
                        type = "filesystem";
                        format = "btrfs";
                        mountOptions = [ "noatime" "compress=zstd" ];
                    };
                };
            };
        };
    };
}
