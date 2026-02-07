builtins.map (path: ../../../home/${path}) [
    "env.nix"

    "services/tpm-fido.nix"

    "plasma/config.nix"
    "plasma/shortcuts.nix"
    "plasma/kvantum.nix"
    "plasma/konsole.nix"
    "plasma/dolphin.nix"
    "plasma/gtk.nix"
    "plasma/applets.nix"
    "plasma/kdeconnect.nix"

    "desktop/userDirs.nix"
    "desktop/wireplumber.nix"

    "dev/c.nix"
    "dev/rust.nix"
    "dev/node.nix"
    "dev/python.nix"
    "dev/java"
    "dev/gradle.nix"
    "dev/editor-config.nix"
    "dev/prettier.nix"

    "applications/tools.nix"
    "applications/chromium.nix"
    "applications/firefox"
    "applications/thunderbird"
    "applications/fzf.nix"
    "applications/git.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/openssh.nix"
    "applications/vscode/client.nix"
    "applications/vscode/server.nix"
    "applications/zsh"
    "applications/steam.nix"
    "applications/prismlauncher.nix"
    "applications/vesktop/default.nix"
    "applications/bitwarden.nix"
    "applications/direnv.nix"
    "applications/helix"
    "applications/libreoffice.nix"
    "applications/bat.nix"
    "applications/nix.nix"
    "applications/wget.nix"
    "applications/podman.nix"
] ++ [
    ./defaultApps.nix

    ./plasma/mouse.nix
    ./plasma/applets.nix
    ./plasma/tiling.nix
    ./plasma/window-rules.nix
    ./plasma/autostart.nix
    ./plasma/monitors.nix
]
