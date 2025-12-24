{ pkgsStable, stableLib, inputs, accentColor, ... }:

let
    loaderCss = /* css */ ''
        @import "${inputs.firefox-mods}/css/colors.css";
        @import "${inputs.firefox-mods}/css/thunderbird_content.css";

        :root {
            --system-hue: ${builtins.toString accentColor.h};
            --system-saturation: ${builtins.toString accentColor.s}%;
            --system-lightness: ${builtins.toString accentColor.l}%;
        }
    '';
in

pkgsStable.runCommand "bundle-css" {} /* bash */ ''
    echo '${loaderCss}' > loader.css
    ${stableLib.getExe pkgsStable.lightningcss} --bundle --minify loader.css -o $out
''
