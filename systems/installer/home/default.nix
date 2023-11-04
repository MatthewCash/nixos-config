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
    "applications/bat.nix"
    "applications/nix.nix"
] ++ [
    ./config-repo.nix
]
