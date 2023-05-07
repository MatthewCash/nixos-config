builtins.map (path: ../../../home/${path}) [
    "env.nix"

    "gnome/tweaks.nix"
    "gnome/console.nix"
    "gnome/gtk.nix"
    "gnome/config.nix"
    "gnome/input/keyboard.nix"
    "gnome/extensions/dash-to-dock.nix"
    "gnome/extensions/gesture-improvements.nix"
    "gnome/extensions/just-perfection.nix"
    "gnome/extensions/tray-icons-reloaded.nix"
    "gnome/extensions/rounded-windows.nix"
    "desktop/defaultApps.nix"
    "desktop/userDirs.nix"

    "dev/c.nix"
    "dev/node.nix"

    "applications/firefox"
    "applications/thunderbird"
    "applications/fzf.nix"
    "applications/git.nix"
    "applications/gnome.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/neovim.nix"
    "applications/openssh.nix"
    "applications/zsh"
    "applications/direnv.nix"
    "applications/helix"
    "applications/editor-config.nix"
] ++ [
    ./gnome.nix
]
