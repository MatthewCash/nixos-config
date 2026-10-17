{ stableLib, pkgsUnstable, ... }:

let
    shared = import ../../nixos/nix-shared.nix;
in
{
    nix = {
        enable = true;

        package = stableLib.mkForce pkgsUnstable.nix;

        inherit (shared) gc settings;
    };
}
