{ stableLib, lib, ... }:

let
    inherit (lib.hm.gvariant) mkUint32;
in

{
    dconf.settings = {
        "org/gnome/desktop/session" = {
            idle-delay = stableLib.mkForce (mkUint32 0);
        };
    };
}
