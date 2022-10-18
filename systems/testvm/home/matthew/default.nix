{ homeName }:

builtins.map (path: ../../../../home/${homeName}/${path}) [
    "persist.nix"

     "gnome/tweaks.nix"
    "gnome/terminal.nix"
    "gnome/gtk.nix"
    "gnome/config.nix"
    "gnome/input/keyboard.nix"
    "gnome/extensions/dash-to-dock.nix"
    "gnome/extensions/gesture-improvements.nix"
    "gnome/extensions/just-perfection.nix"
    "gnome/extensions/tray-icons-reloaded.nix"
    "desktop/defaultApps.nix"

    "applications/chromium.nix"
    "applications/dev.nix"
    "applications/evolution.nix"
    "applications/firefox.nix"
    "applications/fzf.nix"
    "applications/node.nix"
    "applications/git.nix"
    "applications/gnome.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/neovim.nix"
    "applications/openssh.nix"
    "applications/vscode.nix"
    "applications/wsu2fa.nix"
    "applications/zsh.nix"
    "applications/nix.nix"
]
