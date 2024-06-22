{ pkgsStable, pkgsUnstable, stableLib, lib, useImpermanence, persistenceHomePath, name, config, systemConfig, inputs, accentColor, ... }:

let
    webcordConfig = {
        settings = {
            general = {
                menuBar.hide = true;
                tray.disable = false;
                taskbar.flash = true;
                window = {
                    transparent = true;
                    hideOnClose = false;
                };
            };
            privacy = {
                blockApi = {
                    science = true;
                    typingIndicator = true;
                    fingerprinting = true;
                };
                permissions = {
                    video = true;
                    audio = true;
                    fullscreen = true;
                    notifications = true;
                    display-capture = true;
                    background-sync = false;
                };
            };
            advanced = {
                csp.enabled = true;
                cspThirdParty = {
                    spotify = true;
                    gif = true;
                    hcaptcha = true;
                    youtube = true;
                    twitter = true;
                    twitch = true;
                    streamable = true;
                    vimeo = true;
                    soundcloud = true;
                    paypal = true;
                    audius = true;
                    algolia = true;
                    reddit = true;
                    googleStorageApi = true;
                };
                currentInstance.radio = 0;
                devel.enabled = false;
                redirection.warn = true;
                optimize.gpu = false;
                webApi.webGl = true;
                unix.autoscroll = true;
            };
        };
        update.notification = {
            version = "";
            till = "";
        };
        screenShareStore.audio = false;
    };

    configFile = pkgsStable.writeText "config.json" (builtins.toJSON webcordConfig);

    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    systemConfigOptionals = stableLib.optionals (systemConfig != null);
    wrappedWebcord = mkNixPak {
        config = { sloth, ... }: {
            app.package = pkgsUnstable.webcord;
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.freedesktop.Notifications" = "talk";
            };
            flatpak = {
                appId = "org.discord.webcord";
                desktopFile = "webcord.desktop";
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            bubblewrap = {
                bindEntireStore = false;
                bind.rw = [
                    (sloth.concat' sloth.xdgConfigHome "/WebCord")
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    [(sloth.concat' sloth.xdgCacheHome "/webcord/tmp") "/tmp"]
                ];
                bind.ro = [
                    "/etc/fonts"
                    config.home-files # Not in extraStorePaths because we do not want it recursively linked
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ ("${config.gtk.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                ];
                extraStorePaths = (
                    stableLib.attrsets.mapAttrsToList
                        (n: v: v.source)
                        (stableLib.attrsets.filterAttrs (n: v:
                            stableLib.strings.hasPrefix "${config.xdg.configHome}/gtk-3.0" n ||
                            stableLib.strings.hasPrefix "${config.xdg.configHome}/WebCord" n) config.home.file
                        )
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
        ".config/WebCord"
    ];

    home.activation.webcordConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${stableLib.getExe' pkgsUnstable.coreutils "install"} -m=644 ${configFile} ${config.xdg.configHome}/WebCord/config.json
    '';

    xdg.configFile."WebCord/Themes/style.css".text = /* css */ ''
        @import "file://${inputs.discord-css}/style.css";

        :root {
            --system-hue: ${builtins.toString accentColor.h};
            --system-saturation: ${builtins.toString accentColor.s}%;
            --system-lightness: ${builtins.toString accentColor.l}%;
        }
   '';


    home.packages = [ wrappedWebcord.config.env ];
}
