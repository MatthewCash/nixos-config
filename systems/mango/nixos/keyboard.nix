{ ... }:

{
    services.kanata.keyboards.default.extraDefCfg = /* lisp */ ''
        linux-dev-names-include (
            "Glorious Model D"
            "DH747 BCORNE Keyboard"
        )
    '';
}
