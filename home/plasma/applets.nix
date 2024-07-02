{ stableLib, config, persistenceHomePath, name, useImpermanence, ... }:

let
    wallpaperPath = "${config.xdg.dataHome}/backgrounds/current_wallpaper.png";

    containments = [
        # Desktop
        {
            ItemGeometriesHorizontal = "";
            activityId = "808e1ed6-240a-4f8c-ae49-a5d8585809a8";
            formfactor = 0;
            lastScreen = 0;
            location = 0;
            plugin = "org.kde.plasma.folder";
            wallpaperplugin = "org.kde.image";
            General = {
                ToolBoxButtonState = "topcenter";
                ToolBoxButtonX = 300;
            };
            Wallpaper."org.kde.image".General = {
                Color = "0,0,0";
                FillMode = 6;
                Image = wallpaperPath;
                PreviewImage = wallpaperPath;
                SlidePaths = "/run/current-system/sw/share/wallpapers/";
            };
        }

        # Bottom Panel
        {
            activityId = "";
            formfactor = 2;
            lastScreen = 0;
            location = 4;
            plugin = "org.kde.panel";
            applets = [
                {
                    plugin = "org.kde.plasma.kickoff";
                    Configuration = {
                        PreloadWeight = 100;
                        popupHeight = 500;
                        popupWidth = 660;
                        General = {
                            favoritesPortedToKAstats = true;
                            icon = "nix-snowflake-white";
                            systemFavorites = "suspend\,hibernate\,reboot\,shutdown";
                        };
                    };
                }
                {
                    plugin = "org.kde.plasma.taskmanager";
                    Configuration.General = {
                        groupPopups = false;
                        launchers = "";
                        showOnlyCurrentScreen = true;
                    };
                }
                {
                    plugin = "org.kde.plasma.systemmonitor.cpucore";
                    Configuration = {
                        CurrentPreset = "org.kde.plasma.systemmonitor";
                        Appearance = {
                            chartFace = "org.kde.ksysguard.barchart";
                            title = "CPU Usage";
                        };
                        Sensors = {
                            highPrioritySensorIds = ''["cpu/cpu.*/usage"]'';
                            totalSensors = ''["cpu/all/usage"]'';
                        };
                    };
                }
                {
                    plugin = "org.kde.plasma.systemmonitor.memory";
                    Configuration = {
                        CurrentPreset = "org.kde.plasma.systemmonitor";
                        PreloadWeight = 55;
                        Appearance = {
                            chartFace = "org.kde.ksysguard.piechart";
                            title = "Memory Usage";
                        };
                        # SensorColors."memory/physical/used" = "163,99,167";
                        Sensors = {
                            highPrioritySensorIds = ''["memory/physical/used"]'';
                            lowPrioritySensorIds = ''["memory/physical/total"]'';
                            totalSensors = ''["memory/physical/usedPercent"]'';
                        };
                    };
                }
                {
                    plugin = "org.kde.plasma.systemtray";
                    Configuration.SystrayContainmentId = 3;
                }
                {
                    plugin = "org.kde.plasma.digitalclock";
                    Configuration = {
                        popupheight = 450;
                        popupWidth = 800;
                        Appearance = {
                            autoFontAndSize = false;
                            dateDisplayFormat = "BelowTime";
                            dateFormat = "isoDate";
                            enabledCalendarPlugins = "holidaysevents";
                            firstDayOfWeek = 1;
                            fontSize = 12;
                            fontStyleName = "Regular";
                            fontWeight = 400;
                            selectedTimeZones = "America/New_York,Local";
                            showSeconds = "Always";
                            showWeekNumbers = true;
                        };
                    };
                }
            ];
        }

        # System Tray
        {
            activityId = "";
            formFactor = 2;
            lastScreen = 0;
            location = 4;
            plugin = "org.kde.plasma.private.systemtray";
            popupHeight = 450;
            popupWidth = 400;
            applets = builtins.map (name: {
                plugin = name;
            }) [
                "org.kde.plasma.clipboard"
                "org.kde.plasma.devicenotifier"
                "org.kde.plasma.manager-inputmethod"
                "org.kde.plasma.notifications"
                "org.kde.plasma.kscreen"
                "org.kde.plasma.keyboardindicator"
                "org.kde.plasma.keyboardlayout"
                "org.kde.plasma.printmanager"
            ];
        }
    ];

    containmentSettings = builtins.listToAttrs (stableLib.imap0 (i: config: {
        name = builtins.toString (i + 1);
        value = builtins.removeAttrs config [ "applets" ] // { immutability = 1; } //
        stableLib.optionalAttrs (config ? applets && builtins.length config.applets > 0) {
            AppletOrder = stableLib.concatMapStringsSep ";" builtins.toString (stableLib.range 1 (builtins.length config.applets));
            Applets = builtins.listToAttrs (stableLib.imap0 (j: config: {
                name = builtins.toString (j + 1);
                value = config // { immutability = 1; };
            }) config.applets);
        };
    }) containments);
in

{
    home.persistence."${persistenceHomePath}/${name}" = stableLib.mkIf useImpermanence {
        directories = [ ".local/share/backgrounds" ];
    };

    home.sessionVariables.STATIC_WALLPAPER_PATH = wallpaperPath;

    programs.plasma.configFile = {
        "plasma-org.kde.plasma.desktop-appletsrc".Containments = containmentSettings;
        "plasmashellrc".PlasmaViews."Panel 2" = {
            floating = 0;
            panelOpacity = 1;
            Defaults.thickness = 40;
        };
    };
}
