{ nixpkgsUnstable, nixpkgsStable, pkgsUnstable, ... }:

{
    home.sessionVariables = rec {
        EDITOR = "${pkgsUnstable.helix}/bin/hx";
        VISUAL = EDITOR;
    } // {
        # Same variables from config/nix.nix, for non-NixOS systems
        nixpkgsStable = builtins.toString nixpkgsStable;
        nixpkgsUnstable = builtins.toString nixpkgsUnstable;
        nixpkgs = builtins.toString nixpkgsUnstable;
    };
}
