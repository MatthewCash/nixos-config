{ pkgs, inputs, ... }:

{
    nixpkgs.config.allowUnfree = true;

    nix = {
        package = pkgs.nixFlakes;

        settings.auto-optimise-store = true;

        gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 30d";
        };

        extraOptions = ''
            experimental-features = nix-command flakes
        '';
        
        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    };
}
