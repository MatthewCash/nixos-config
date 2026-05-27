{ stableLib, inputs, system, persistPath, ... }:

let
    plasma-video-wallpaper = inputs.plasma-video-wallpaper.packages.${system}.default;
in

{
    environment.systemPackages = [
        plasma-video-wallpaper
    ];

    environment.persistence.${persistPath}.files = [
        "/etc/plasma/wallpaper_video"
    ];

    # for some reason wallpaper config can't be in /etc/plasmalogin.conf.d
    environment.etc."plasmalogin.conf".text = stableLib.generators.toINI { mkSectionName = stableLib.id; } {
        Greeter.WallpaperPluginId = "simplevideowallpaper";
        "Greeter][Wallpaper][simplevideowallpaper][General" = {
            source = "/etc/plasma/wallpaper_video";
        };
    };
}
