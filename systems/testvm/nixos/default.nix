builtins.map (path: ../../../nixos/${path}) [
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
    "fs/disks.nix"
    "fs/lvm.nix"
    "env.nix"
    "docs.nix"
    "pam-mount.nix"
    "systemd/config.nix"
    "systemd/logind.nix"
    "dbus.nix"
    "kmscon.nix"

    "applications/general.nix"
] ++ [
    ./networking.nix
    ./disks.nix
]
