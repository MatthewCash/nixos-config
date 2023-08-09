builtins.map (path: ../../../config/${path}) [
    "users.nix"
    "time.nix"
    "console.nix"
    "sudo.nix"
    "pam.nix"
    "nix.nix"
    "kernel.nix"
    "fonts.nix"
    "boot.nix"
    "networking/general.nix"
    "networking/openssh.nix"
    "networking/firewall/nftables.nix"
    "hardware/keyboard.nix"
    "hardware/hyperv.nix"
    "fs/mounts.nix"
    "fs/lvm.nix"
    "ld.nix"
    "env.nix"
    "docs.nix"
    "systemd/config.nix"
    "kmscon.nix"
    "dbus.nix"
    "podman.nix"

    "applications/general.nix"
] ++ [
    ./networking.nix
    ./firewall/nftables.nix
    ./mounts.nix
]
