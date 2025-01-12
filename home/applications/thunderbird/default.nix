args @ { pkgsStable, pkgsUnstable, systemConfig, config, stableLib, useImpermanence, persistenceHomePath, name, inputs, accentColor, ... }:

let
    thunderbird = pkgsUnstable.thunderbird.override {
        extraPolicies = import ./policy.nix args;
    };

    systemConfigOptionals = stableLib.optionals (systemConfig != null);

    wrappedThunderbird = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; } {
        config = { sloth, ... }: rec {
            app.package = thunderbird;
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.gnome.SessionManager" = "talk";
                "org.gtk.vfs.*" = "talk";
                "org.freedesktop.Notifications" = "talk";
                "org.mozilla.thunderbird_default.*" = "own";
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            flatpak.session-helper.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bindEntireStore = false;
                bind.rw = [
                    (sloth.concat' sloth.homeDir "/.thunderbird")
                    (sloth.concat' sloth.xdgCacheHome "/thunderbird")
                    (sloth.concat' sloth.runtimeDir "/gvfs")
                    (sloth.concat' sloth.runtimeDir "/gvfsd")
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                ];
                bind.dev = [
                    "/sys/class/hidraw"
                    "/sys/devices/virtual/misc/uhid"
                    (sloth.realpath (sloth.concat' sloth.runtimeDir "/tpm-fido-hidrawnode"))
                ];
                bind.ro = [
                    "/etc/fonts"
                    (builtins.toString config.home-files) # Not in extraStorePaths because we do not want it recursively linked
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ "${app.package}/lib/thunderbird/mozilla.cfg" "/app/etc/thunderbird/mozilla.cfg" ]
                ];
                extraStorePaths = (
                    stableLib.attrsets.mapAttrsToList
                        (n: v: v.source)
                        (stableLib.attrsets.filterAttrs (n: v: stableLib.strings.hasPrefix ".thunderbird" n) config.home.file)
                ) ++ systemConfigOptionals [
                    systemConfig.hardware.graphics.package # WebRender acceleration
                    (stableLib.strings.removeSuffix "/etc/fonts/" systemConfig.environment.etc.fonts.source) # Fonts
                ] ++ systemConfigOptionals systemConfig.hardware.graphics.extraPackages; # Video acceleration
                sockets = {
                    wayland = true;
                    pipewire = true;
                    pulse = true;
                };
            };
        };
    };
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".thunderbird"
        ".cache/thunderbird"
    ];

    programs.thunderbird = {
        enable = true;
        package = wrappedThunderbird.config.env;
        profiles = {
            "main" = {
                isDefault = true;
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
