{ pkgsUnstable, inputs, system, ... }:

let
    plasmaVideoWallpaper = inputs.plasma-video-wallpaper.packages.${system}.default;

    deterministicTaskManager = pkgsUnstable.kdePackages.callPackage
        ./deterministic-task-manager/default.nix {};

    taskManagerOrderedAppIds = [
        # screen 1
        "thunderbird"
        "org.mozilla.Firefox.layout"
        "org.kde.dolphin"
        "org.kde.konsole"
        "org.mozilla.Firefox.floating"
        "org.prismlauncher.PrismLauncher"
        "AxolotlClient 1.21.11"
        "steam"
        "steam_app_244210" # content manager
        "assetto-corsa"
        # screen 2
        "org.mozilla.Firefox.transparent"
        "com.discord.vesktop.personal"
        "com.discord.vesktop.business"
        "guitarix"
        "channel-mixer"
    ];

    taskManagerConfig = {
        showOnlyCurrentScreen = true;
        taskMaxWidth = "Narrow";
        launchers = [];
        orderedAppIds = taskManagerOrderedAppIds;

        sortingStrategy = 7;
    };

    wallpaperConfig = {
        plugin = "simplevideowallpaper";
        config.General.source = "file:///mnt/home/matthew/videos/toronto_wallpaper.mp4";
    };

in

{
    home.packages = with pkgsUnstable; [
        nixos-icons
        plasmaVideoWallpaper
        deterministicTaskManager
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
                        name = "org.kde.plasma.taskmanagerordered";
                        config.General = taskManagerConfig;
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
                        name = "org.kde.plasma.taskmanagerordered";
                        config.General = taskManagerConfig;
                    }
                    "org.kde.plasma.systemmonitor.cpucore"
                    "org.kde.plasma.systemmonitor.memory"
                ];
            }
        ];
    };
}
