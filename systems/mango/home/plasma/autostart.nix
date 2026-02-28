{ stableLib, pkgsStable, config, lib, ... }:

let
    autoStartApps = [
        "thunderbird"
        "org.kde.dolphin"
        "org.kde.konsole"
        "org.mozilla.Firefox.floating"
        "org.prismlauncher.PrismLauncher"
        "assetto-corsa"

        "org.mozilla.Firefox.layout"
        "com.discord.vesktop.personal"
        "com.discord.vesktop.business"
    ];
in

{
    # There has to be a better way to do this ???
    home.activation.plasmaAutostartApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (stableLib.concatMapStringsSep "\n" (entry: ''
        $DRY_RUN_CMD ${stableLib.getExe' pkgsStable.coreutils "ln"} -sf \
            "${config.home.profileDirectory}/share/applications/${entry}.desktop" \
            "${config.xdg.configHome}/autostart/${entry}.desktop"
    '') autoStartApps);
}
