{ ssd, ... }:

{
    programs.fuse.userAllowOther = true;

    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/nixos"
            "/var/lib/systemd/coredump"
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

    age.identityPaths = [
        "/nix/persist/etc/ssh/ssh_host_ed25519_key"
        "/nix/persist/home/matthew/.ssh/id_matthew"
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
