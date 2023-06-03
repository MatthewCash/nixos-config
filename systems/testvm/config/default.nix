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
    "hardware/keyboard.nix"
    "hardware/hyperv.nix"
    "de/gnome.nix"
    "fs/mounts.nix"
    "fs/lvm.nix"
    "env.nix"
    "docs.nix"
    "pam-mount.nix"
    "systemd/config.nix"
    "secureboot.nix"
    "dbus.nix"
    "kmscon.nix"

    "applications/general.nix"
] ++ [
    ./networking.nix
    ./gnome.nix
    ./mounts.nix
]
