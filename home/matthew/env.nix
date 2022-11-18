{ pkgsUnstable, ... }:

{
    home.sessionVariables = rec {
        EDITOR = "${pkgsUnstable.helix}/bin/hx";
        VISUAL = EDITOR;
        STATIC_WALLPAPER_PATH = "$HOME/.local/share/backgrounds/current_wallpaper.png";
    };
}
