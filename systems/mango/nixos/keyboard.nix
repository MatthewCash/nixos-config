{ pkgsUnstable, ... }:

{
    services.kanata.keyboards.default.extraDefCfg = /* lisp */ ''
        linux-dev-names-include (
            "Glorious Model D"
            "DH747 BCORNE Keyboard"
        )
    '';

    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [ pkgsUnstable.vial ];
}
