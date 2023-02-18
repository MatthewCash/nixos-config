{ homeName }:

builtins.map (path: ../../../../home/${homeName}/${path}) [
    "env.nix"

    "applications/dev.nix"
    "applications/fzf.nix"
    "applications/node.nix"
    "applications/git.nix"
    "applications/gpg.nix"
    "applications/htop.nix"
    "applications/neovim.nix"
    "applications/openssh.nix"
    "applications/zsh.nix"
    "applications/vscode-server.nix"
    "applications/direnv.nix"
    "applications/helix"
    "applications/gradle.nix"
    "applications/editor-config.nix"
    "applications/omnisharp.nix"
]
