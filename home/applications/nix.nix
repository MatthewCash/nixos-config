{ stableLib, pkgsUnstable, ... }:

{
    nix = {
        enable = true;

        package = stableLib.mkForce pkgsUnstable.nix;

        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            use-xdg-base-directories = true;
        };
    };
}
