{ ... }:

{
    services.kmscon = {
        enable = true;
        extraConfig = ''
            xkb-layout=us
            xkb-variant=colemak_dh
        '';
    };
}
