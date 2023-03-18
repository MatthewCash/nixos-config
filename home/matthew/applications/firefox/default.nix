args @ { pkgsUnstable, persistenceHomePath, name, inputs, accentColor, system, ... }:

let
    firefox-devedition-bin = pkgsUnstable.firefox-devedition-bin.override (old: {
        icon = "firefox-developer-edition";
        desktopName = "Firefox Developer Edition";
        nameSuffix = "";
        extraPolicies = import ./policy.nix args;
        wmClass = "firefox-aurora";
    });
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".mozilla"
        ".cache/mozilla"
    ];

    programs.firefox = {
        enable = true;
        package = firefox-devedition-bin;
        profiles = {
            "main" = {
                name = "dev-edition-default";
                isDefault = true;
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
                settings = import ./settings.nix;
            };
        };
    };
}
