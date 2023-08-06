args @ { stableLib, pkgsStable, pkgsUnstable, useImpermanence, persistenceHomePath, inputs, name, ... }:

let
    # Get the latest package from either channel, shouldn't cause an issues since changes usually get backported
    firefoxPackages = [ pkgsStable.firefox-devedition pkgsUnstable.firefox-devedition ];
    latestFirefox = stableLib.lists.last
        (builtins.sort (a: b: builtins.compareVersions a.version b.version < 0) firefoxPackages);

    firefox-devedition = latestFirefox.override (old: {
        icon = "firefox-developer-edition";
        extraPolicies = import ./policy.nix args;
        extraPrefsFiles = [
            "${inputs.firefox-mods}/install_dir/config.js"
        ];
    });

    profileNames = builtins.attrNames (stableLib.attrsets.filterAttrs (n: v: v == "regular") (builtins.readDir ./profiles));
    profileList = stableLib.lists.imap0 (i: name: {
        name = builtins.substring 0 (builtins.stringLength name - 4) name;
        value = import ./profiles/${name} args // {
            id = i;
        };
    }) profileNames;
    profiles = builtins.listToAttrs profileList;
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".mozilla"
        ".cache/mozilla"
    ];

    programs.firefox = {
        enable = true;
        package = firefox-devedition;
        profiles = profiles // {
            "floating".name = "dev-edition-default";
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
