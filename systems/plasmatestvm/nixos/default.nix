builtins.map (path: ../../../nixos/${path}) [
    "users.nix"
    "virt.nix"
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
    "de/plasma.nix"
    "fs/disks.nix"
    "fs/lvm.nix"
    "ld.nix"
    "env.nix"
    "docs.nix"
    "pam-mount.nix"
    "systemd/config.nix"
    "dbus.nix"
    "kmscon.nix"
    "flatpak.nix"
    "podman.nix"
] ++ [
    ./networking.nix
    ./disks.nix
]
