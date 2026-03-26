{ inputs, accentColor, ... }:

{
    userChrome = /* css */ ''
        @import "${inputs.firefox-mods}/css/chrome/colors.css";
        @import "${inputs.firefox-mods}/css/chrome/layout.css";

        :root {
            --system-hue: ${builtins.toString accentColor.h};
            --system-saturation: ${builtins.toString accentColor.s}%;
            --system-lightness: ${builtins.toString accentColor.l}%;
        }
    '';
    userContent = /* css */ ''
        @import "${inputs.firefox-mods}/userContent.css";

        :root {
            --system-hue: ${builtins.toString accentColor.h};
            --system-saturation: ${builtins.toString accentColor.s}%;
            --system-lightness: ${builtins.toString accentColor.l}%;
        }
        
        @-moz-document regexp("^moz-extension:\/\/.*\/sidebar\/sidebar\.html.*$") {
            span {
                font-size: 12px !important;
                font-family: 'Aurebesh AF', sans-serif !important;
            }
        }
    '';
    settings = import ../settings.nix;
}
