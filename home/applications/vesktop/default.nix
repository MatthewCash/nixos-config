args @ { pkgsStable, pkgsUnstable, stableLib, customLib, useImpermanence, persistenceHomePath, name, config, systemConfig, inputs,  ... }:

let
    # configFile = pkgsStable.writeText "config.json" (builtins.toJSON webcordConfig);

    profileNames = [ "personal" "business" ];

    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    systemConfigOptionals = stableLib.optionals (systemConfig != null);
    wrappedVesktops = builtins.map (profileName: mkNixPak {
        config = { sloth, ... }: {
            app.package = (pkgsStable.symlinkJoin {
                name = "vesktop-${profileName}";
                paths = [ pkgsUnstable.vesktop ];
                buildInputs = [ pkgsStable.makeWrapper ];
                postBuild = let
                    desktopEntry = (builtins.elemAt pkgsUnstable.vesktop.desktopItems 0).override rec {
                        name = "vesktop-${profileName}";
                        exec = name;
                        desktopName = "Vesktop ${customLib.capitalizeFirstLetter profileName}";
                        startupWMClass = "Vesktop";
                    };
                in /* bash */ ''
                    rm $out/share/applications/vesktop.desktop
                    install -D -T ${desktopEntry}/share/applications/* "$out/share/applications/org.discord.vesktop.${profileName}.desktop"
                    makeWrapper '${stableLib.getExe pkgsUnstable.vesktop}' $out/bin/vesktop-${profileName}
                '';
                meta.mainProgram = "vesktop-${profileName}";
            }).overrideAttrs { desktopItems = []; };
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.freedesktop.Notifications" = "talk";
            };
            flatpak = {
                appId = "org.discord.vesktop.${profileName}";
                session-helper.enable = true;
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bindEntireStore = false;
                bind.rw = [
                    [(sloth.concat' sloth.xdgConfigHome "/vesktop-${profileName}") (sloth.concat' sloth.xdgConfigHome "/vesktop")]
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    [(sloth.concat' sloth.xdgCacheHome "/vesktop/tmp") "/tmp"]
                ];
                bind.ro = [
                    "/etc/fonts"
                    (builtins.toString config.home-files) # Not in extraStorePaths because we do not want it recursively linked
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ ("${config.gtk.gtk3.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                ];
                extraStorePaths = (
                    stableLib.attrsets.mapAttrsToList
                        (n: v: v.source)
                        (stableLib.attrsets.filterAttrs (n: v:
                            stableLib.strings.hasPrefix "${config.xdg.configHome}/gtk-3.0" n ||
                            stableLib.strings.hasPrefix "${config.xdg.configHome}/vesktop-${profileName}/" n) config.home.file
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
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence (stableLib.map (name: ".config/vesktop-${name}")profileNames);

    xdg.configFile = stableLib.mergeAttrsList (builtins.map (profileName: {
        "vesktop-${profileName}/themes/theme.css".source = import ./theme.nix args;
       "vesktop-${profileName}/state.json".text = builtins.toJSON {
           firstLaunch = false;
       };
       "vesktop-${profileName}/settings.json".text = builtins.toJSON (import ./settings.nix);
       "vesktop-${profileName}/settings/settings.json".text = builtins.toJSON (import ./vencord-settings.nix);
    }) profileNames);

    home.packages = builtins.map (vesktop: vesktop.config.env) wrappedVesktops;
}
