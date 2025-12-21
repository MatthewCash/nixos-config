args @ { stableLib, customLib, pkgsStable, pkgsUnstable, useImpermanence, persistenceHomePath, inputs, name, systemConfig, config, ... }:

let
    firefoxPackage = pkgsUnstable.firefox-devedition;

    firefox = (firefoxPackage.override (old: {
        icon = "firefox-developer-edition";
        extraPolicies = import ./policy.nix args;
        extraPrefsFiles = [
            "${inputs.firefox-mods}/install_dir/config.js"
        ];
    })).overrideAttrs (oldAttrs: {
        # Remove default desktop entry (setting desktopEntry to null does not work :/)
        buildCommand = builtins.replaceStrings [ "install -D -t $out/share/applications" ] [ "#removed" ] oldAttrs.buildCommand;
    });

    profileFileNames = builtins.attrNames
        (stableLib.attrsets.filterAttrs (n: v: v == "regular")
        (builtins.readDir ./profiles));

    profileNames = builtins.map (stableLib.strings.removeSuffix ".nix") profileFileNames;

    flatpakId = "org.mozilla.Firefox";
    getWMClass = profileName: "${flatpakId}.${profileName}";
    wmClasses = builtins.map getWMClass profileNames;
    binName = firefox.meta.mainProgram;

    desktopFiles = builtins.map ({ fst, snd }: firefox.desktopItem.override (old: {
        desktopName = "Firefox ${customLib.capitalizeFirstLetter fst}";
        exec = "${binName} -P ${fst} --name ${snd} %U";
        actions.new-window = {
            inherit (old.actions.new-window) name;
            exec = "${binName} -P ${fst} --name ${snd} --new-window %U";
        };
        actions.new-private-window = {
            inherit (old.actions.new-private-window) name;
            exec = "${binName} -P ${fst} --name ${snd} --private-window %U";
        };
        actions.profile-manager-window = old.actions.profile-manager-window;
        startupWMClass = snd;
        extraConfig.X-Flatpak = flatpakId;
    })) (stableLib.lists.zipLists profileNames wmClasses);

    installCommands = stableLib.strings.concatMapStringsSep
        "\n"
        ({ fst, snd }: "install -D -T ${fst}/share/applications/* $out/share/applications/${snd}.desktop")
        (stableLib.lists.zipLists desktopFiles wmClasses);

    dconfSettings = stableLib.optionalAttrs (config.gtk.gtk3.theme.name != null) {
        "org/gnome/desktop/interface".gtk-theme = config.gtk.gtk3.theme.name;
    };

    dconfDb = customLib.generateDconfDb dconfSettings;

    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    systemConfigOptionals = stableLib.optionals (systemConfig != null);
    wrappedFirefox = mkNixPak {
        config = { sloth, ... }: rec {
            app.package = firefox.overrideAttrs (oldAttrs: {
                buildCommand = oldAttrs.buildCommand + installCommands;
            });
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.gnome.SessionManager" = "talk";
                "org.freedesktop.Screensaver" = "talk";
                "org.gtk.vfs.*" = "talk";
                "org.freedesktop.Notifications" = "talk";
                "org.mpris.MediaPlayer2.firefox.*" = "own";
                "org.mozilla.firefox.*" = "own";
                "org.mozilla.firefox_beta.*" = "own";
            };
            flatpak = {
                appId = flatpakId;
                session-helper.enable = true;
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bindEntireStore = false;
                bind.rw = [
                    (sloth.concat' sloth.homeDir "/.mozilla")
                    (sloth.concat' sloth.xdgCacheHome "/mozilla")
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
                    [ (builtins.toString dconfDb) (sloth.concat' sloth.xdgConfigHome "/dconf/user") ]
                    [ ("${config.gtk.gtk3.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    [ "${app.package}/lib/${app.package.pname}/mozilla.cfg" "/app/etc/firefox/mozilla.cfg" ]
                ];
                extraStorePaths = (
                    stableLib.attrsets.mapAttrsToList
                        (n: v: v.source)
                        (stableLib.attrsets.filterAttrs
                            (n: v: stableLib.isStorePath v.source && stableLib.strings.hasPrefix ".mozilla" n)
                            config.home.file)
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

    profileList = stableLib.lists.imap0 (i: name: {
        name = builtins.substring 0 (builtins.stringLength name - 4) name;
        value = import ./profiles/${name} args // import ./common.nix args // { id = i; };
    }) profileFileNames;
    profiles = builtins.listToAttrs profileList;
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".mozilla"
        ".cache/mozilla"
    ];

    programs.firefox = {
        enable = true;
        package = null; # Since Firefox is already wrapped (with nixpak) it is not specified here
        inherit profiles;
    };

    home.packages = [ wrappedFirefox.config.env ];

    # Enable JS mods in 'layout' profile
    home.file.".mozilla/firefox/layout/chrome/firefox-mods".source = inputs.firefox-mods;
    home.file.".mozilla/firefox/layout/chrome/chrome.manifest".text = "content mods ./";
    home.file.".mozilla/firefox/layout/chrome/entrypoint.js".text = /* js */ ''
        const EXPORTED_SYMBOLS = [];
        ChromeUtils.importESModule('chrome://mods/content/firefox-mods/js/main.js');
    '';
}
