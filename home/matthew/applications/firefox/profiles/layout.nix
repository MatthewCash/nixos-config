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
    '';
    settings = import ../settings.nix;
}
