{ nixpkgsUnstable, nixpkgsStable, pkgsUnstable, stableLib, ... }:

{
    home.sessionVariables = rec {
        EDITOR = stableLib.getExe pkgsUnstable.helix;
        VISUAL = EDITOR;
    } // {
        # Same variables from config/nix.nix, for non-NixOS systems
        nixpkgsStable = builtins.toString nixpkgsStable;
        nixpkgsUnstable = builtins.toString nixpkgsUnstable;
        nixpkgs = builtins.toString nixpkgsUnstable;
    };
}
