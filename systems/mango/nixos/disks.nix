{ stableLib, ... }:

let
    windowsMounts = {
        windows = "e3fe1ee6-8bce-44d5-bf65-3f93f053dac8";
        storage = "1c6496e9-412a-4b4d-8da1-49e33a9eaf92";
        archive = "0f7176cf-2f44-408e-8357-bc9e9fd4a25f";
        data = "5047919b-bf8a-4fb4-8b7a-406c24abba30";
    };

    mkWindowsMounts = names: builtins.map (name: {
        description = "Mount BitLocker volume ${name}";
        requires = [ "systemd-cryptsetup@${name}.service" ];
        after = [ "systemd-cryptsetup@${name}.service" ];
        wantedBy = [ "multi-user.target" ];

        what = "/dev/mapper/${name}";
        where = "/mnt/${name}";
        type = "ntfs3";
        options = "ro,uid=1000,nofail";
    }) names;
in

{
    environment.etc."crypttab".text = stableLib.concatStringsSep
        "\n"
        (stableLib.mapAttrsToList
            (name: uuid: "${name} UUID=${uuid} /mnt/persist/etc/bitlk-keys/${name} bitlk,nofail")
        windowsMounts);

    systemd.mounts = mkWindowsMounts (builtins.attrNames windowsMounts);

    disko.devices = {
        disk.main = {
            device = "/dev/disk/by-id/nvme-SPCC_M.2_PCIe_SSD_RN001290";
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
            nix.size = "1T";
            persist.size = "1T";
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
                size = "1T";
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
                    settings = {
                        bypassWorkqueues = true;
                        allowDiscards = true;
                    };
                };
            };
        };
    };
}
