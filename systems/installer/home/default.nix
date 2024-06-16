builtins.map (path: ../../../home/${path}) [
    "env.nix"

    "applications/tools.nix"
    "applications/fzf.nix"
    "applications/git.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/openssh.nix"
    "applications/zsh"
    "applications/helix"
    "applications/bat.nix"
    "applications/nix.nix"
    "applications/wget.nix"
] ++ [
    ./config-repo.nix
]
