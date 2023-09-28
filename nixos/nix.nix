{ nixpkgsStable, nixpkgsUnstable, ... }:

{
    nix = {
        settings.auto-optimise-store = true;

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };

        extraOptions = ''
            experimental-features = nix-command flakes
        '';

        nixPath = [ "nixpkgs=${nixpkgsUnstable}" ];
    };

    environment.variables = {
        inherit nixpkgsStable nixpkgsUnstable;
        nixpkgs = nixpkgsUnstable;
    };
}
