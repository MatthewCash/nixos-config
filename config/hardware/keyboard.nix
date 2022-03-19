{ pkgs, ... }:

let
    colemakDh = ''
        default partial alphanumeric_keys

        // overwrite some keys with the Mod-DH config
        xkb_symbols "colemak_dh" {
            // get the base colemak layout
            include "us(colemak)"
            // use AltGr as a 3rd modifier
            include "level3(ralt_switch)"

            key <AD05> { [ b, B, enfilledcirclebullet, Greek_beta ] };
            key <AC05> { [ g, G, eng, ENG ] };
            key <AC06> { [ k, K, ccedilla, Ccedilla ] };
            key <AB04> { [ d, D, eth, ETH ] };
            key <AB05> { [ v, V, division, Greek_gamma ] };
            key <AB06> { [ m, M, multiply, downarrow ] };
            key <AB07> { [ h, H, hstroke, Hstroke] };
        };
    '';

    colemakDhFile = pkgs.writeText "colemak-dh" colemakDh;
in

{
    services.xserver = {
        extraLayouts = {
            "colemak_dh" = {
                description = "Colemak layout with DH mods";
                languages = [ "eng" ];
                symbolsFile = colemakDhFile;
            };
        };
        layout = "us";
        xkbVariant = "colemak_dh";
    };
}
