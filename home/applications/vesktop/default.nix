args @ { pkgsStable, pkgsUnstable, stableLib, customLib, useImpermanence, persistenceHomePath, name, config, inputs,  ... }:

let
    profileNames = [ "personal" "business" ];

    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    wrappedVesktops = builtins.map (profileName: mkNixPak {
        config = { sloth, ... }: let
            vesktop =  ((pkgsUnstable.vesktop.override { withSystemVencord = true; }).overrideAttrs (old: {
                # patch to override wayland app_id
                postPatch = old.postPatch or "" + ''
                    ${stableLib.getExe pkgsStable.jq} '.desktopName = "com.discord.vesktop.${profileName}"' package.json > package.json.tmp
                    mv package.json.tmp package.json
                '';
            }));
        in {
            app.package = (pkgsStable.symlinkJoin {
                name = "vesktop-${profileName}";
                paths = [  ];
                buildInputs = [ pkgsStable.makeWrapper ];
                postBuild = let
                    desktopEntry = (builtins.elemAt pkgsUnstable.vesktop.desktopItems 0).override rec {
                        name = "vesktop-${profileName}";
                        exec = name;
                        icon = "discord";
                        desktopName = "Vesktop ${customLib.capitalizeFirstLetter profileName}";
                        startupWMClass = "com.discord.vesktop.${profileName}";
                    };
                in /* bash */ ''
                    install -D -T ${desktopEntry}/share/applications/* "$out/share/applications/com.discord.vesktop.${profileName}.desktop"
                    makeWrapper '${stableLib.getExe vesktop}' $out/bin/vesktop-${profileName}
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
                appId = "com.discord.vesktop.${profileName}";
                session-helper.enable = true;
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bind.rw = [
                    [(sloth.concat' sloth.xdgConfigHome "/vesktop-${profileName}") (sloth.concat' sloth.xdgConfigHome "/vesktop")]
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    [(sloth.concat' sloth.xdgCacheHome "/vesktop/tmp") "/tmp"]
                ];
                bind.ro = [
                    "/etc/fonts"
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ ("${config.gtk.gtk3.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                ];
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
        "vesktop-${profileName}/state.json".text = builtins.toJSON { firstLaunch = false; };
        "vesktop-${profileName}/settings.json".text = builtins.toJSON (import ./settings.nix);
        "vesktop-${profileName}/settings/settings.json".text = builtins.toJSON (import ./vencord-settings.nix);
    }) profileNames);

    home.packages = builtins.map (vesktop: vesktop.config.env) wrappedVesktops;
}
