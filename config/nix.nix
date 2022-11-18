{ nixpkgsStable, nixpkgsUnstable, system, ... }:

{
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

        nixPath = [ "nixpkgs=${nixpkgsUnstable}" ];
    };

    environment.variables = {
        nixpkgsStable = builtins.toString nixpkgsStable;
        nixpkgsUnstable = builtins.toString nixpkgsUnstable;
        nixpkgs = builtins.toString nixpkgsUnstable;
    };
}
