{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ tray-icons-reloaded ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "trayIconsReloaded@selfmade.pl" ];
}
