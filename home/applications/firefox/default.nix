args @ { stableLib, pkgsUnstable, useImpermanence, persistenceHomePath, name, ... }:

let
    firefox-devedition = pkgsUnstable.firefox-devedition.override (old: {
        icon = "firefox-developer-edition";
        desktopName = "Firefox Developer Edition";
        nameSuffix = "";
        extraPolicies = import ./policy.nix args;
        wmClass = "firefox-aurora";
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
}
