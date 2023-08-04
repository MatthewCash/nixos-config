{ pkgsUnstable, stableLib, ... }:

{
    home.sessionVariables.QT_STYLE_OVERRIDE = stableLib.mkForce "kvantum";

    programs.plasma.configFile."Kvantum/kvantum.kvconfig" = {
        General.theme = "Sweet";
    };

    xdg.configFile."Kvantum/Sweet".source = "${pkgsUnstable.sweet-nova}/share/Kvantum/Sweet";

    home.packages = with pkgsUnstable; [ libsForQt5.qtstyleplugin-kvantum ];
}
