{ stableLib, inputs, system, persistPath, ... }:

{
    environment.systemPackages = [
        inputs.plasma-smart-video-wallpaper-reborn.packages.${system}.default
    ];

    environment.persistence.${persistPath}.files = [
        "/etc/plasma/wallpaper_video"
    ];

    # for some reason wallpaper config can't be in /etc/plasmalogin.conf.d
    environment.etc."plasmalogin.conf".text = stableLib.generators.toINI { mkSectionName = stableLib.id; } {
        Greeter.WallpaperPluginId = "luisbocanegra.smart.video.wallpaper.reborn";
        "Greeter][Wallpaper][luisbocanegra.smart.video.wallpaper.reborn][General" = {
            VideoUrls = builtins.toJSON [
                {
                    filename = "/etc/plasma/wallpaper_video";
                    enabled = true;
                }
            ];
            BatteryPausesVideo = false;
            FillMode = 1;
            PauseMode = 3;
        };
    };
}
