{ pkgsUnstable, pkgsStable, customLib, stableLib, useImpermanence, persistenceHomePath, name, inputs, config, ... }:

let
    dconfSettings = stableLib.optionalAttrs (config.gtk.gtk3.theme.name != null) {
        "org/gnome/desktop/interface".gtk-theme = config.gtk.gtk3.theme.name;
    };

    dconfDb = customLib.generateDconfDb dconfSettings;

    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    wrappedChromium = mkNixPak {
        config = { sloth, ... }: {
            app.package = pkgsUnstable.chromium.override {
                commandLineArgs = [
                    "--enable-features=UseOzonePlatform"
                    "--ozone-platform=wayland"
                    "--ignore-gpu-blocklist"
                    "--enable-features=VaapiVideoDecoder"
                ];
            };
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.freedesktop.Notifications" = "talk";
                "org.mpris.MediaPlayer2.chromium.*" = "own";
                "org.freedesktop.Screensaver" = "talk";
            };
            flatpak = {
                appId = "org.google.chromium";
                desktopFile = "chromium-browser.desktop";
                session-helper.enable = true;
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bind.rw = [
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    (sloth.concat' sloth.xdgConfigHome "/chromium")
                    (sloth.concat' sloth.xdgCacheHome "/chromium")
                    [(sloth.concat' sloth.xdgCacheHome "/chromium/tmp") "/tmp"]
                ];
                bind.ro = [
                    "/etc/fonts"
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ ("${config.gtk.gtk3.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    [ (builtins.toString dconfDb) (sloth.concat' sloth.xdgConfigHome "/dconf/user") ]
                    (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
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
    home.persistence."${persistenceHomePath}".directories = stableLib.mkIf useImpermanence [
        ".config/chromium"
        ".cache/chromium"
    ];

    systemd.user.tmpfiles.rules = [ "d ${config.xdg.cacheHome}/chromium/tmp - - - - -"];

    programs.chromium = {
        enable = true;
        package = wrappedChromium.config.env;
        extensions = [
            { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        ];
    };
}
