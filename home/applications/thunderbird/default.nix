args @ { pkgsStable, pkgsUnstable, customLib, config, stableLib, useImpermanence, persistenceHomePath, name, inputs, lib, ... }:

let
    thunderbird = pkgsUnstable.thunderbird.override {
        extraPolicies = import ./policy.nix args;
    };

    dconfSettings = stableLib.optionalAttrs (config.gtk.gtk3.theme.name != null) {
        "org/gnome/desktop/interface".gtk-theme = config.gtk.gtk3.theme.name;
    };

    dconfDb = customLib.generateDconfDb dconfSettings;

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
                    [ ("${config.gtk.gtk3.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ (builtins.toString dconfDb) (sloth.concat' sloth.xdgConfigHome "/dconf/user") ]
                    [ "${app.package}/lib/thunderbird/mozilla.cfg" "/app/etc/thunderbird/mozilla.cfg" ]
                ];
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

    home.packages = [ wrappedThunderbird.config.env ];

    programs.thunderbird = {
        enable = true;
        package = pkgsUnstable.gnused; # Since Thunderbird is already wrapped (with nixpak) it is not specified here;
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
