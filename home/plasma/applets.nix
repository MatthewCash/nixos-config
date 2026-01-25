{ pkgsUnstable, config, persistenceHomePath, ... }:

let
    wallpaperPath = "${config.xdg.dataHome}/backgrounds/current_wallpaper.png";
in

{
    home.persistence."${persistenceHomePath}" = {
        directories = [ ".local/share/backgrounds" ];
    };

    home.sessionVariables.STATIC_WALLPAPER_PATH = wallpaperPath;
}
