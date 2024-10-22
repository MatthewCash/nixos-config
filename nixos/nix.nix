{ nixpkgsStable, nixpkgsUnstable, ... }:

{
    nix = {

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };

        settings = {
            auto-optimise-store = true;
            experimental-features = [ "nix-command" "flakes" ];
            use-xdg-base-directories = true;
            trusted-users = [ "@wheel" ];
        };

        nixPath = [ "nixpkgs=${nixpkgsUnstable}" ];
    };

    environment.variables = {
        inherit nixpkgsStable nixpkgsUnstable;
        nixpkgs = nixpkgsUnstable;
    };
}
