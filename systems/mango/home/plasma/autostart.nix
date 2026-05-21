{ config, lib, ... }:

let
    autoStartApps = [
        "thunderbird"
        "org.mozilla.Firefox.layout"
        "org.kde.dolphin"
        "org.kde.konsole"
        "org.mozilla.Firefox.floating"
        "prismlauncher-enderscale"
        "assetto-corsa"

        "org.mozilla.Firefox.transparent"
        "com.discord.vesktop.personal"
        "com.discord.vesktop.business"
    ];
in

{
    xdg.configFile = lib.listToAttrs (map (entry: {
        name = "autostart/${entry}.desktop";
        value = {
            force = true;
            source = config.lib.file.mkOutOfStoreSymlink "${config.home.profileDirectory}/share/applications/${entry}.desktop";
        };
    }) autoStartApps);
}
