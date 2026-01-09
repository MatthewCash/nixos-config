{ stableLib, pkgsUnstable, config, persistenceHomePath, name, useImpermanence, ... }:

let
    wallpaperPath = "${config.xdg.dataHome}/backgrounds/current_wallpaper.png";
in

{
    home.persistence."${persistenceHomePath}" = stableLib.mkIf useImpermanence {
        directories = [ ".local/share/backgrounds" ];
    };

    home.packages = with pkgsUnstable; [ nixos-icons ];

    home.sessionVariables.STATIC_WALLPAPER_PATH = wallpaperPath;

    programs.plasma.panels = [
        {
            location = "bottom";
            widgets = [
                {
                    name = "org.kde.plasma.kickoff";
                    config.General.icon = "nix-snowflake-white";
                }
                {
                    name = "org.kde.plasma.taskmanager";
                    config.General = {
                        showOnlyCurrentScreen = true;
                        taskMaxWidth = "Narrow";
                        launchers = "";
                    };
                }
                "org.kde.plasma.systemmonitor.cpucore"
                "org.kde.plasma.systemmonitor.memory"
                "org.kde.plasma.systemtray"
                {
                    name = "org.kde.plasma.digitalclock";
                    config.Appearance = {
                        showSeconds = "Always";
                        showWeekNumbers = true;
                        dateFormat = "isoDate";

                        autoFontAndSize = false;
                        fontSize = 12;
                        fontStyleName = "Regular";
                        fontWeight = 400;
                    };
                }
            ];
        }
    ];
}
