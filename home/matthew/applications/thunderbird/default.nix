args @ { pkgsUnstable, persistenceHomePath, name, inputs, accentColor, ... }:

let
    thunderbird = pkgsUnstable.thunderbird.override (old: {
        extraPolicies = import ./policy.nix args;
    });
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".thunderbird"
        ".cache/thunderbird"
    ];

    programs.thunderbird = {
        enable = true;
        package = thunderbird;
        profiles = {
            "main" = {
                isDefault = true;
                userChrome = /* css */ ''
                    /*@import "${inputs.firefox-mods}/css/chrome/colors.css";*/

                   /* :root {
                        --system-hue: ${builtins.toString accentColor.h};
                        --system-saturation: ${builtins.toString accentColor.s}%;
                        --system-lightness: ${builtins.toString accentColor.l}%;
                    }*/
                '';
                userContent = /* css */ ''
                    @import "${inputs.firefox-mods}/userContent.css";

                    :root {
                        --system-hue: ${builtins.toString accentColor.h};
                        --system-saturation: ${builtins.toString accentColor.s}%;
                        --system-lightness: ${builtins.toString accentColor.l}%;
                    }
                '';
                settings = import ./settings.nix;
            };
        };
    };
}
