{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ tray-icons-reloaded ];

    dconf.settings = {
        "org/gnome/shell".enabled-extensions = [ "trayIconsReloaded@selfmade.pl" ];
        "org/gnome/shell/extensions/trayIconsReloaded".icon-size = 16;
    };
}
