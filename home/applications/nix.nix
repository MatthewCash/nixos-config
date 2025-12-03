{ stableLib, pkgsUnstable, systemConfig, ... }:

{
    nix = {
        enable = true;

        package = stableLib.mkForce pkgsUnstable.nix;

        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            use-xdg-base-directories = true;
        };
    } // (if systemConfig == null then {
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };

        settings.auto-optimise-store = true;
    } else {});
}
