{ homeName }:

builtins.map (path: ../../../../home/${homeName}/${path}) [
    "env.nix"
    "services/tpm-fido.nix"
    "gnome/tweaks.nix"
    "gnome/console.nix"
    "gnome/totem.nix"
    "gnome/gtk.nix"
    "gnome/config.nix"
    "gnome/kvantum.nix"
    "gnome/input/touchpad.nix"
    "gnome/input/keyboard.nix"
    "gnome/extensions/dash-to-dock.nix"
    "gnome/extensions/gesture-improvements.nix"
    "gnome/extensions/just-perfection.nix"
    "gnome/extensions/tray-icons-reloaded.nix"
    "gnome/extensions/rounded-windows.nix"
    "desktop/defaultApps.nix"
    "desktop/userDirs.nix"

    "dev/c.nix"
    "dev/rust.nix"
    "dev/node.nix"
    "dev/java"

    "applications/chromium.nix"
    "applications/evolution.nix"
    "applications/firefox"
    "applications/fzf.nix"
    "applications/git.nix"
    "applications/gnome.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/neovim.nix"
    "applications/openssh.nix"
    "applications/vscode.nix"
    "applications/zsh"
    "applications/steam.nix"
    "applications/prismlauncher.nix"
    "applications/webcord.nix"
    "applications/setzer.nix"
    "applications/bitwarden.nix"
    "applications/direnv.nix"
    "applications/helvum.nix"
    "applications/helix"
    "applications/editor-config.nix"
    "applications/libreoffice.nix"
] ++ [
    ./firefox.nix
]
