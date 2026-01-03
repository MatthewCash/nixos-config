{ ... }:

{
    services.xserver.xkb = {
        layout = "us";
        variant = "colemak_dh";
    };

    services.kanata = {
        enable = true;
        keyboards.default = {
            extraDefCfg = ''
                linux-device-detect-mode keyboard-only
            '';
            config = /* lisp */ ''
                (defsrc
                    caps
                    mfwd
                    mbck
                    lctrl
                    mmid
                )

                (deflayer default
                    esc ;; map caps locks -> escape
                    mfwd
                    mbck
                    (multi lctrl (layer-while-held wm))
                    (multi mmid (layer-while-held wm))
                )

                (deflayermap wm
                    mfwd (multi (release-key lctl) M-pgup)
                    mbck (multi (release-key lctl) M-pgdn)
                )
            '';
        };
    };
}
