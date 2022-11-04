{ pkgs, nixpkgs, ... }:

{
    nixpkgs.config.allowUnfree = true;

    nix = {
        settings.auto-optimise-store = true;

        gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 30d";
        };

        extraOptions = ''
            experimental-features = nix-command flakes
        '';

        nixPath = [ "nixpkgs=${nixpkgs}" ];
    };

    environment.variables.nixpkgs = builtins.toString nixpkgs;
}
