{ stableLib, pkgsStable, pkgsUnstable, inputs, useImpermanence, config, systemConfig, persistenceHomePath, name, ... }:

let
    systemConfigOptionals = stableLib.optionals (systemConfig != null);

    wrappedEvolution = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; } {
        config = { sloth, ... }: {
            app.package = pkgsUnstable.evolutionWithPlugins.override
                { plugins = with pkgsUnstable; [ evolution evolution-ews ]; };
            app.binPath = "bin/evolution";
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.gnome.SessionManager" = "talk";
                "org.gtk.vfs.*" = "talk";
                "org.freedesktop.Notifications" = "talk";
                "org.gnome.OnlineAccounts" = "talk";
                "org.freedesktop.secrets" = "talk";
                "org.gnome.keyring.SystemPrompter" = "talk";
                "org.gnome.Evolution" = "own";
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            bubblewrap = {
                bindEntireStore = false;
                bind.rw = [
                    (sloth.concat' sloth.xdgDataHome "/evolution")
                    (sloth.concat' sloth.xdgCacheHome "/evolution")
                    (sloth.concat' sloth.xdgConfigHome "/evolution")
                    (sloth.concat' sloth.runtimeDir "/gvfs")
                    (sloth.concat' sloth.runtimeDir "/gvfsd")
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    (sloth.concat' sloth.runtimeDir "/at-spi/bus") # a11y bus
                ];
                bind.ro = [
                    "/etc/fonts"
                    config.home-files # Not in extraStorePaths because we do not want it recursively linked
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                ];
                extraStorePaths = (
                    stableLib.attrsets.mapAttrsToList
                        (n: v: v.source)
                        (stableLib.attrsets.filterAttrs (n: v: stableLib.strings.hasPrefix ".thunderbird" n) config.home.file)
                ) ++ systemConfigOptionals [
                    systemConfig.hardware.opengl.package
                    (stableLib.strings.removeSuffix "/etc/fonts/" systemConfig.environment.etc.fonts.source) # Fonts
                ] ++ systemConfigOptionals systemConfig.hardware.opengl.extraPackages; # Video acceleration
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
        ".local/share/evolution"
        ".config/evolution"
        ".cache/evolution"
    ];

    home.packages = [ wrappedEvolution.config.env ];

    dconf.settings."org/gnome/evolution/mail" = {
        layout = 1;
        show-to-do-bar = false;
        show-to-do-bar-sub = false;
        mark-seen-timeout = 0;
        prompt-on-mark-all-read = false;
    };

    dconf.settings."org/gnome/evolution/mail/browser-window" = {
        height = 400;
        width = 600;
        maximized = false;
    };

    dconf.settings."org/gnome/evolution/mail/composer-window" = {
        height = 800;
        width = 1150;
        show-to-do-bar = false;
        show-to-do-bar-sub = false;
        maximized = false;
    };

    dconf.settings."org/gnome/evolution/shell" = {
        attachment-view = 0;
        autoar-filter = "none";
        autoar-format = "zip";
        buttons-visible = true;
        buttons-visible-sub = true;
        default-component-id = "mail";
        folder-bar-width = 263;
        folder-bar-width-sub = 259;
        menubar-visible = false;
        menubar-visible-sub = false;
        sidebar-visible = true;
        sidebar-visible-sub = true;
        statusbar-visible = false;
        statusbar-visible-sub = true;
        toolbar-visible = false;
        toolbar-visible-sub = true;
    };

    dconf.settings."org/gnome/evolution/shell/window" = {
        height = 1080;
        maximized = false;
        width = 1920;
        x = 0;
        y = 0;
    };

    # Prefer plain text messages
    dconf.settings."org/gnome/evolution/plugin/prefer-plain" = {
        mode = "prefer_source";
    };
}
