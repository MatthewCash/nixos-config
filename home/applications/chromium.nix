{ pkgsUnstable, pkgsStable, stableLib, useImpermanence, persistenceHomePath, name, inputs, config, systemConfig, ... }:

let
    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    systemConfigOptionals = stableLib.optionals (systemConfig != null);
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
                bindEntireStore = false;
                bind.rw = [
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    (sloth.concat' sloth.xdgConfigHome "/chromium")
                    (sloth.concat' sloth.xdgCacheHome "/chromium")
                    [(sloth.concat' sloth.xdgCacheHome "/chromium/tmp") "/tmp"]
                ];
                bind.ro = [
                    "/etc/fonts"
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ ("${config.gtk.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                ];
                extraStorePaths = (
                    stableLib.attrsets.mapAttrsToList
                        (n: v: v.source)
                        (stableLib.attrsets.filterAttrs (n: v: stableLib.strings.hasPrefix "${config.xdg.configHome}/gtk-3.0" n) config.home.file)
                ) ++ systemConfigOptionals [
                    systemConfig.hardware.graphics.package
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
