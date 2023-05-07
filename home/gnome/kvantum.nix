{ pkgsUnstable, stableLib, inputs, ... }:

{
    home.sessionVariables.QT_STYLE_OVERRIDE = stableLib.mkForce "kvantum";

    xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=KvLibadwaitaDark
    '';
    xdg.configFile."Kvantum/KvLibadwaita".source = "${inputs.kvlibadwaita}/src/KvLibadwaita";

    home.packages = with pkgsUnstable; [ libsForQt5.qtstyleplugin-kvantum ];
}
