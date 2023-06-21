builtins.map (path: ../../../home/${path}) [
    "env.nix"

    "applications/tools.nix"
    "applications/fzf.nix"
    "applications/git.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/neovim.nix"
    "applications/openssh.nix"
    "applications/zsh"
    "applications/helix"
    "applications/editor-config.nix"
    "applications/bat.nix"
] ++ [
    ./config-repo.nix
]
