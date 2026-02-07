{ stableLib, pkgsUnstable, inputs, system, ... }:

let
    wallpaperConfig = {
        plugin = "luisbocanegra.smart.video.wallpaper.reborn";
        config.General.VideoUrls = builtins.toJSON [
            {
                filename = "/mnt/home/matthew/videos/toronto_wallpaper.mp4";
                enabled = true;
            }
        ];
    };

in

{
    home.packages = with pkgsUnstable; [
        nixos-icons
        inputs.plasma-smart-video-wallpaper-reborn.packages.${system}.default
    ];

    programs.plasma = {
        workspace.wallpaperCustomPlugin = wallpaperConfig;
        kscreenlocker.appearance.wallpaperCustomPlugin = wallpaperConfig;

        panels = [
            {
                screen = 0;
                location = "bottom";
                height = 40;
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
                            launchers = stableLib.concatMapStringsSep "," (x: "applications:${x}") [
                                "thunderbird.desktop"
                                "org.mozilla.Firefox.layout.desktop"
                                "org.kde.dolphin.desktop"
                                "org.kde.konsole.desktop"
                                "org.mozilla.Firefox.floating.desktop"
                                "org.prismlauncher.PrismLauncher.desktop"
                            ];
                        };
                    }
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
            rec {
                screen = 1;
                location = "bottom";
                alignment = "left";
                height = 45;
                maxLength = 3840 / 2 + 4;
                minLength = maxLength;
                floating = true;
                hiding = "windowsgobelow";
                widgets = [
                    {
                        name = "org.kde.plasma.taskmanager";
                        config.General = {
                            showOnlyCurrentScreen = true;
                            taskMaxWidth = "Narrow";
                            launchers = stableLib.concatMapStringsSep "," (x: "applications:${x}") [
                                "org.mozilla.Firefox.layout.desktop"
                                "com.discord.vesktop.personal.desktop"
                                "com.discord.vesktop.business.desktop"
                            ];
                        };
                    }
                    "org.kde.plasma.systemmonitor.cpucore"
                    "org.kde.plasma.systemmonitor.memory"
                ];
            }
        ];
    };
}
