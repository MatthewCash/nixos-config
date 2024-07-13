{ ... }:

let
    espSizeMiB = 512;
in

{
    disk = {
        mainDisk = {
            type = "disk";
            device = "/dev/sda";
            content = {
                type = "table";
                format = "gpt";
                partitions = [
                    {
                        type = "partition";
                        name = "efi";
                        start = "1MiB";
                        end = "${builtins.toString espSizeMiB}MiB";
                        bootable = true;
                        content = {
                            type = "filesystem";
                            format = "vfat";
                            mountpoint = "/boot";
                        };
                    }
                    {
                        type = "partition";
                        name = "lvm";
                        start = "${builtins.toString.espSizeMiB}MiB";
                        end = "100%";
                        content = {
                            type = "luks";
                            name = "crypt-name";
                            content = {
                                type = "lvm_pv";
                                vg = "main";
                            };
                        };
                    }
                ];
            };
        };
    };

    lvm_vg = {
        pool = {
            type = "lvm_vg";
            lvs = {
                nix = {
                    type = "lvm_lv";
                    size = "100G";
                    content = {
                        type = "filesystem";
                        format = "btrfs";
                        mountPoint = "/nix";
                        mountOptions = [ "noatime" ];
                    };
                };
                persist = {
                    type = "lvm_lv";
                    size = "100G";
                    content = {
                        type = "filesystem";
                        format = "btrfs";
                        mountPoint = "/nix";
                        mountOptions = [ "noatime" ];
                    };
                };
                swap = {
                    type = "lvm_lv";
                    size = "30G";
                    content = {
                        type = "swap";
                    };
                };
                home-matthew = {
                    type = "lvm_lv";
                    size = "100G";
                    content = {
                        type = "luks";
                        name = "crypt-home-matthew";
                        content = {
                            type = "filesystem";
                            format = "brtfs";
                            mountOptions = [ "noatime" ];
                        };
                    };
                };
            };
        };
    };

    tmpfs = {
        root = {
            type = "tmpfs";
            mountPoint = "/";
            mountOptions = [ "size=4G" ];
        };
    };
}
