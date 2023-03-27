builtins.map (path: ../../../${path}) [
    "config/users.nix"
    "config/time.nix"
    "config/console.nix"
    "config/sudo.nix"
    "config/pam.nix"
    "config/nix.nix"
    "config/kernel.nix"
    "config/boot.nix"
    "config/networking/general.nix"
    "config/networking/openssh.nix"
    "config/networking/firewall/nftables.nix"
    "config/hardware/keyboard.nix"
    "config/hardware/hyperv.nix"
    "config/fs/mounts.nix"
    "config/fs/lvm.nix"
    "config/ld.nix"
    "config/env.nix"
    "config/docs.nix"
    "config/systemd/config.nix"

    "config/applications/general.nix"
] ++ [
    ./networking.nix
    ./firewall/nftables.nix
    ./mounts.nix
]
