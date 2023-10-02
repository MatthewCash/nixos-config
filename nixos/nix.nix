{ nixpkgsStable, nixpkgsUnstable, ... }:

{
    nix = {
        settings.auto-optimise-store = true;

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };

        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            use-xdg-base-directories = true;
        };

        nixPath = [ "nixpkgs=${nixpkgsUnstable}" ];
    };

    environment.variables = {
        inherit nixpkgsStable nixpkgsUnstable;
        nixpkgs = nixpkgsUnstable;
    };
}
