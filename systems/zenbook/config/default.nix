builtins.map (path: ../../../config/${path}) [
    "users.nix"
    "time.nix"
    "console.nix"
    "sudo.nix"
    "printing.nix"
    "pam.nix"
    "nix.nix"
    "kernel.nix"
    "fonts.nix"
    "boot.nix"
    "secureboot.nix"
    "audio.nix"
    "acpi.nix"
    "networking/general.nix"
    "networking/dispatcherScripts/captivePortal.nix"
    "networking/openssh.nix"
    "networking/firewall/fail2ban.nix"
    "networking/firewall/nftables.nix"
    "hardware/tpm.nix"
    "hardware/keyboard.nix"
    "hardware/gpu.nix"
    "hardware/battery.nix"
    "hardware/usbguard.nix"
    "de/gnome.nix"
    "cpu/intel.nix"
    "fs/mounts.nix"
    "fs/lvm.nix"
    "ld.nix"
    "env.nix"
    "docs.nix"
    "tailscale.nix"
    "pam-mount.nix"
    "uhid.nix"
    "systemd/config.nix"
    "bluetooth.nix"
    "fwupd.nix"
    "services/evolution.nix"
    "dbus.nix"
    "kmscon.nix"
    "podman.nix"

    "applications/general.nix"
] ++ [
    ./kernel.nix
    ./networking.nix
    ./firewall/nftables.nix
    ./gpu.nix
    ./mounts.nix
    ./lid.nix
    ./usbguard.nix
]
