{ pkgsUnstable, stableLib, accentColor, ... }:

let
    accentName = builtins.substring 1 6 accentColor.hex;
    sweetTheme = pkgsUnstable.runCommand "sweet-kvantum-${accentName}" {} ''
        mkdir $out
        cp ${pkgsUnstable.sweet-nova}/share/Kvantum/Sweet/Sweet.kvconfig $out/Sweet.kvconfig
        cp ${pkgsUnstable.sweet-nova}/share/Kvantum/Sweet/Sweet.svg $out/Sweet.svg

        substituteInPlace $out/Sweet.kvconfig \
            --replace-fail "highlight.color=#c50ed2" "highlight.color=${accentColor.hex}" \
            --replace-fail "inactive.highlight.color=#654ea3" "inactive.highlight.color=${accentColor.hex}" \
            --replace-fail "link.color=#646464" "link.color=${accentColor.hex}" \
            --replace-fail "link.visited.color=#7f8c8d" "link.visited.color=${accentColor.hex}"
        substituteInPlace $out/Sweet.svg \
            --replace-fail "#ff00cc" "${accentColor.hex}" \
            --replace-fail "#333399" "${accentColor.hex}" \
            --replace-fail "#c50ed2" "${accentColor.hex}"
    '';
in

{
    home.sessionVariables.QT_STYLE_OVERRIDE = stableLib.mkForce "kvantum";

    programs.plasma.configFile."Kvantum/kvantum.kvconfig" = {
        General.theme = "Sweet";
    };

    xdg.configFile."Kvantum/Sweet/Sweet.kvconfig".source = "${sweetTheme}/Sweet.kvconfig";
    xdg.configFile."Kvantum/Sweet/Sweet.svg".source = "${sweetTheme}/Sweet.svg";

    home.packages = with pkgsUnstable; [
        libsForQt5.qtstyleplugin-kvantum
        kdePackages.qtstyleplugin-kvantum
    ];
}
