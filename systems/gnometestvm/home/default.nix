builtins.map (path: ../../../home/${path}) [
    "env.nix"

    "gnome/tweaks.nix"
    "gnome/console.nix"
    "gnome/gtk.nix"
    "gnome/config.nix"
    "gnome/kvantum.nix"
    "gnome/input/keyboard.nix"
    "gnome/extensions/dash-to-dock.nix"
    "gnome/extensions/just-perfection.nix"
    "gnome/extensions/tray-icons-reloaded.nix"

    "desktop/userDirs.nix"

    "dev/c.nix"
    "dev/node.nix"
    "dev/python.nix"
    "dev/editor-config.nix"

    "applications/tools.nix"
    "applications/firefox"
    "applications/thunderbird"
    "applications/fzf.nix"
    "applications/git.nix"
    "applications/gnome.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/openssh.nix"
    "applications/zsh"
    "applications/direnv.nix"
    "applications/helix"
    "applications/bat.nix"
    "applications/nix.nix"
    "applications/wget.nix"
    "applications/evolution.nix"
] ++ [
    ./defaultApps.nix

    ./gnome.nix
]
