{ pkgsStable, stableLib, inputs, accentColor, ... }:

let
    loaderCss = /* css */ ''
        @import "${inputs.discord-css}/style.css";

        :root {
            --system-hue: ${builtins.toString accentColor.h};
            --system-saturation: ${builtins.toString accentColor.s}%;
            --system-lightness: ${builtins.toString accentColor.l}%;
        }

        html * {
            font-family: "Aurebesh AF" !important;
        }
    '';
in

pkgsStable.runCommand "bundle-css" {} /* bash */ ''
    echo '${loaderCss}' > loader.css
    ${stableLib.getExe pkgsStable.lightningcss} --bundle --minify loader.css -o $out
''
