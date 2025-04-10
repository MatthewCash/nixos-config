{ pkgsStable, pkgsUnstable, stableLib, lib, customLib, useImpermanence, persistenceHomePath, name, config, systemConfig, inputs, accentColor, ... }:

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

    profileNames = [ "personal" "business" ];

    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    systemConfigOptionals = stableLib.optionals (systemConfig != null);
    wrappedWebcords = builtins.map (profileName: mkNixPak {
        config = { sloth, ... }: {
            app.package = (pkgsStable.symlinkJoin {
                name = "webcord-${profileName}";
                paths = [ pkgsUnstable.webcord ];
                buildInputs = [ pkgsStable.makeWrapper ];
                postBuild = let
                    desktopEntry = (builtins.elemAt pkgsUnstable.webcord.desktopItems 0).override rec {
                        name = "webcord-${profileName}";
                        exec = name;
                        desktopName = "Webcord ${customLib.capitalizeFirstLetter profileName}";
                    };
                in /* bash */ ''
                    rm $out/share/applications/webcord.desktop
                    install -D -T ${desktopEntry}/share/applications/* "$out/share/applications/org.discord.webcord.${profileName}.desktop"
                    makeWrapper '${stableLib.getExe pkgsUnstable.webcord}' $out/bin/webcord-${profileName}
                '';
                meta.mainProgram = "webcord-${profileName}";
            }).overrideAttrs { desktopItems = []; };
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.freedesktop.Notifications" = "talk";
            };
            flatpak = {
                appId = "org.discord.webcord.${profileName}";
                session-helper.enable = true;
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bindEntireStore = false;
                bind.rw = [
                    [(sloth.concat' sloth.xdgConfigHome "/webcord-${profileName}") (sloth.concat' sloth.xdgConfigHome "/WebCord")]
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    [(sloth.concat' sloth.xdgCacheHome "/webcord/tmp") "/tmp"]
                ];
                bind.ro = [
                    "/etc/fonts"
                    (builtins.toString config.home-files) # Not in extraStorePaths because we do not want it recursively linked
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ ("${config.gtk.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                ];
                extraStorePaths = (
                    stableLib.attrsets.mapAttrsToList
                        (n: v: v.source)
                        (stableLib.attrsets.filterAttrs (n: v:
                            stableLib.strings.hasPrefix "${config.xdg.configHome}/gtk-3.0" n ||
                            stableLib.strings.hasPrefix "${config.xdg.configHome}/webcord-${profileName}/" n) config.home.file
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
    }) profileNames;
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence (stableLib.map (name: ".config/webcord-${name}")profileNames);

    home.activation.webcordConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] (stableLib.strings.concatMapStringsSep "\n" (name: ''
        $DRY_RUN_CMD ${stableLib.getExe' pkgsUnstable.coreutils "install"} -m=644 ${configFile} ${config.xdg.configHome}/webcord-${name}/config.json
    '') profileNames);

    xdg.configFile = builtins.listToAttrs (builtins.map (profileName: {
        name = "webcord-${profileName}/Themes/style.css";
        value.text = /* css */ ''
            @import "file://${inputs.discord-css}/style.css";

            :root {
                --system-hue: ${builtins.toString accentColor.h};
                --system-saturation: ${builtins.toString accentColor.s}%;
                --system-lightness: ${builtins.toString accentColor.l}%;
            }

            html * {
                font-family: "Aurebesh AF" !important;
            }
       '';
    }) profileNames);

    home.packages = builtins.map (webcord: webcord.config.env) wrappedWebcords;
}
