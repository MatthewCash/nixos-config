{ pkgsUnstable, stableLib, inputs, ... }:

{
    home.sessionVariables = {
        QT_STYLE_OVERRIDE = stableLib.mkForce "kvantum";
        QT_WAYLAND_DECORATION = stableLib.mkForce "adwaita";
    };

    xdg.configFile."Kvantum/kvantum.kvconfig".text = stableLib.generators.toINI {} {
        General.theme = "KvLibadwaitaDark";
    };
    xdg.configFile."Kvantum/KvLibadwaita".source = "${inputs.kvlibadwaita}/src/KvLibadwaita";

    home.packages = with pkgsUnstable; [
        libsForQt5.qtstyleplugin-kvantum
        kdePackages.qtstyleplugin-kvantum
        qadwaitadecorations
        qadwaitadecorations-qt6
    ];
}
