builtins.map (path: ../../../config/${path}) [
    "users.nix"
    "time.nix"
    "console.nix"
    "sudo.nix"
    "pam.nix"
    "nix.nix"
    "kernel.nix"
    "fonts.nix"
    "networking/general.nix"
    "networking/openssh.nix"
    "hardware/keyboard.nix"
    "fs/lvm.nix"
    "ld.nix"
    "env.nix"
    "docs.nix"
    "systemd/config.nix"
    "kmscon.nix"

    "applications/general.nix"
] ++ [
    ./networking.nix
    ./kmscon.nix
]
