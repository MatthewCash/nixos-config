{ lib, ... }:

let
    gvariant = lib.hm.gvariant;
    inherit (gvariant) mkTuple;
in

{
    dconf.settings = {
        "org/gnome/desktop/input-sources" = {
            sources = [ (mkTuple [ "xkb" "us+colemak_dh" ]) (mkTuple ["xkb" "us"]) ];
            xkb-options = [ "caps:escape" ];
        };
    };
}
