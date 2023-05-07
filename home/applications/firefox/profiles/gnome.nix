{ inputs, accentColor, ... }:

{
    userChrome = /* css */ ''
        @import "${inputs.firefox-gnome-theme}/userChrome.css";
        @import "${inputs.firefox-mods}/css/chrome/colors.css";

        :root {
            --system-hue: ${builtins.toString accentColor.h};
            --system-saturation: ${builtins.toString accentColor.s}%;
            --system-lightness: ${builtins.toString accentColor.l}%;
        }

        /* remove active tab outline */
        .tab-background {
            outline: none !important;
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
    extraConfig = builtins.readFile "${inputs.firefox-gnome-theme}/configuration/user.js";
    settings = import ../settings.nix;
}
