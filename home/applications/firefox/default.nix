args @ { stableLib, pkgsStable, pkgsUnstable, useImpermanence, persistenceHomePath, inputs, name, ... }:

let

    firefox-devedition = (pkgsUnstable.firefox-devedition.override (old: {
        icon = "firefox-developer-edition";
        extraPolicies = import ./policy.nix args;
        extraPrefsFiles = [
            "${inputs.firefox-mods}/install_dir/config.js"
        ];
    })).overrideAttrs(oldAttrs: {
        # Remove default desktop entry (setting desktopEntry to null does not work :/)
        buildCommand = builtins.replaceStrings [ "install -D -t $out/share/applications" ] [ "#removed" ] oldAttrs.buildCommand;
    });

    profileNames = builtins.attrNames (stableLib.attrsets.filterAttrs (n: v: v == "regular") (builtins.readDir ./profiles));
    profileList = stableLib.lists.imap0 (i: name: {
        name = builtins.substring 0 (builtins.stringLength name - 4) name;
        value = import ./profiles/${name} args // {
            id = i;
        };
    }) profileNames;
    profiles = builtins.listToAttrs profileList;

    baseDesktopEntry = {
        name = "Firefox";
        genericName = "Web Browser";
        icon = "firefox-developer-edition";
        terminal = false;
        categories = [ "Network" "WebBrowser" ];
        mimeType = [ "text/html" "text/xml" ];
    };
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".mozilla"
        ".cache/mozilla"
    ];

    programs.firefox = {
        enable = true;
        package = firefox-devedition;
        inherit profiles;
    };

    xdg.desktopEntries = {
        firefoxLayout = baseDesktopEntry // {
            name = "Firefox Layout";
            exec = "firefox --no-remote -P layout --name ff-layout %U";
            settings.StartupWMClass = "ff-layout";
        };
        firefoxFloating = baseDesktopEntry // {
            name = "Firefox Floating";
            exec = "firefox --no-remote -P floating --name ff-floating %U";
            settings.StartupWMClass = "ff-floating";
        };
        firefoxGnome = baseDesktopEntry // {
            name = "Firefox Gnome";
            exec = "firefox --no-remote -P gnome --name ff-gnome %U";
            settings.StartupWMClass = "ff-gnome";
        };
    };

    # Enable JS mods in 'layout' profile
    home.file.".mozilla/firefox/layout/chrome/firefox-mods".source = inputs.firefox-mods;
    home.file.".mozilla/firefox/layout/chrome/chrome.manifest".text = "content mods ./";
    home.file.".mozilla/firefox/layout/chrome/entrypoint.js".text = /* js */ ''
        const EXPORTED_SYMBOLS = [];
        Components.utils.import('chrome://mods/content/firefox-mods/js/main.js');
    '';
}
