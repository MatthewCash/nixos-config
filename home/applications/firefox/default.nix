args @ { stableLib, customLib, pkgsStable, pkgsUnstable, persistenceHomePath, inputs, config, ... }:

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
    getAppId = profileName: "${flatpakId}.${profileName}";
    binName = firefox.meta.mainProgram;

    dconfSettings = stableLib.optionalAttrs (config.gtk.gtk3.theme.name != null) {
        "org/gnome/desktop/interface".gtk-theme = config.gtk.gtk3.theme.name;
    };

    dconfDb = customLib.generateDconfDb dconfSettings;

    mkNixPak = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; };
    wrappedFirefoxes = builtins.map (profileName: mkNixPak {
        config = { sloth, ... }: let
            appId = getAppId profileName;
            launcherName = "${binName}-${profileName}";
            desktopEntry = firefox.desktopItem.override (old: {
                desktopName = "Firefox ${customLib.capitalizeFirstLetter profileName}";
                exec = "${launcherName} -P ${profileName} --name ${appId} %U";
                actions.new-window = {
                    inherit (old.actions.new-window) name;
                    exec = "${launcherName} -P ${profileName} --name ${appId} --new-window %U";
                };
                actions.new-private-window = {
                    inherit (old.actions.new-private-window) name;
                    exec = "${launcherName} -P ${profileName} --name ${appId} --private-window %U";
                };
                actions.profile-manager-window = {
                    inherit (old.actions.profile-manager-window) name;
                    exec = "${launcherName} --ProfileManager";
                };
                startupWMClass = appId;
            });
        in rec {
            app.package = (pkgsStable.symlinkJoin {
                name = launcherName;
                paths = [];
                buildInputs = [ pkgsStable.makeWrapper ];
                postBuild = ''
                    install -D -T ${desktopEntry}/share/applications/* "$out/share/applications/${appId}.desktop"
                    makeWrapper '${stableLib.getExe firefox}' "$out/bin/${launcherName}"
                '';
                meta.mainProgram = launcherName;
            }).overrideAttrs { desktopItems = []; };
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
                inherit appId;
                session-helper.enable = true;
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bind.rw = [
                    (sloth.concat' sloth.xdgConfigHome "/mozilla")
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
                    [ ("${config.gtk.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ (builtins.toString dconfDb) (sloth.concat' sloth.xdgConfigHome "/dconf/user") ]
                    [ ("${config.gtk.gtk3.theme.package}/share/themes") (sloth.concat' sloth.xdgDataHome "/themes") ]
                    [ "${firefox}/lib/${firefox.pname}/mozilla.cfg" "/app/etc/firefox/mozilla.cfg" ]
                ];
                sockets = {
                    wayland = true;
                    pipewire = true;
                    pulse = true;
                };
            };
        };
    }) profileNames;

    profileList = stableLib.lists.imap0 (i: name: {
        name = builtins.substring 0 (builtins.stringLength name - 4) name;
        value = import ./profiles/${name} args // import ./common.nix args // { id = i; };
    }) profileFileNames;
    profiles = builtins.listToAttrs profileList;
in

{
    home.persistence."${persistenceHomePath}".directories = [
        ".config/mozilla"
        ".cache/mozilla"
    ];

    programs.firefox = {
        enable = true;
        package = null; # Since Firefox is already wrapped (with nixpak) it is not specified here
        inherit profiles;
    };

    home.packages = builtins.map (wrappedFirefox: wrappedFirefox.config.env) wrappedFirefoxes;

    # Enable JS mods in 'transparent' profile
    xdg.configFile."mozilla/firefox/transparent/chrome/firefox-mods".source = inputs.firefox-mods;
    xdg.configFile."mozilla/firefox/transparent/chrome/chrome.manifest".text = "content mods ./";
    xdg.configFile."mozilla/firefox/transparent/chrome/entrypoint.js".text = /* js */ ''
        const EXPORTED_SYMBOLS = [];
        ChromeUtils.importESModule('chrome://mods/content/firefox-mods/js/main.js');
    '';
}
