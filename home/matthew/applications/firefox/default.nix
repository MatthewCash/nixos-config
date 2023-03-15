args @ { pkgsUnstable, persistenceHomePath, name, inputs, accentColor, system, ... }:

let
    firefox-devedition-bin = pkgsUnstable.firefox-devedition-bin.override (old: {
        icon = "firefox-developer-edition";
        desktopName = "Firefox Developer Edition";
        nameSuffix = "";
        extraPolicies = import ./policy.nix args;
        wmClass = "firefox-aurora";
    });

    handlers = builtins.toJSON {
        mimeTypes =  {
            "application/pdf" = {
                action = 3;
                extension = [ "pdf" ];
            };
        };
    };
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

                    /* remove margin from Firefox View */
                    tabs#tabbrowser-tabs {
                        border-inline-start: unset !important;
                        padding-inline-start: unset !important;
                        margin-inline-start: unset !important;
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
