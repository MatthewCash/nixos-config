{ pkgs, ... }:

{
    home.packages = with pkgs.gnomeExtensions; [ tray-icons-reloaded ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "trayIconsReloaded@selfmade.pl" ];
}
