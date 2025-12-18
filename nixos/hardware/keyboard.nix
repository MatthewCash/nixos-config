{ ... }:

{
    services.xserver.xkb = {
        layout = "us";
        variant = "colemak_dh";
    };

    services.kanata = {
        enable = true;
        keyboards.default = {
            extraDefCfg = "process-unmapped-keys yes";
            config = /* lisp */ ''
                (defsrc
                    caps
                    mfwd
                    mbck
                )

                ;; set some aliases for raising/lowering windows
                (defalias
                    mf (fork mfwd (multi (release-key lctl) M-pgup) (lctl mmid))
                    mb (fork mbck (multi (release-key lctl) M-pgdn) (lctl mmid))
                )

                (deflayer default
                    esc ;; map caps locks -> escape
                    @mf
                    @mb
                )
            '';
        };
    };
}
