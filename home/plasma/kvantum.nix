{ pkgsUnstable, stableLib, accentColor, ... }:

let
    sweetConfig = pkgsUnstable.runCommand "Sweet.kvconfig" {} ''
        cp ${pkgsUnstable.sweet-nova}/share/Kvantum/Sweet/Sweet.kvconfig $out
        substituteInPlace $out \
            --replace-fail "highlight.color=#c50ed2" "highlight.color=${accentColor.hex}" \
            --replace-fail "inactive.highlight.color=#654ea3" "inactive.highlight.color=${accentColor.hex}" \
            --replace-fail "link.color=#646464" "link.color=${accentColor.hex}"
    '';
in

{
    home.sessionVariables.QT_STYLE_OVERRIDE = stableLib.mkForce "kvantum";

    programs.plasma.configFile."Kvantum/kvantum.kvconfig" = {
        General.theme = "Sweet";
    };

    xdg.configFile."Kvantum/Sweet/Sweet.kvconfig".source = sweetConfig;
    xdg.configFile."Kvantum/Sweet/Sweet.svg".source = "${pkgsUnstable.sweet-nova}/share/Kvantum/Sweet/Sweet.svg";

    home.packages = with pkgsUnstable; [
        libsForQt5.qtstyleplugin-kvantum
        kdePackages.qtstyleplugin-kvantum
    ];
}
