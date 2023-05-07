{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ rounded-window-corners ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "rounded-window-corners@yilozt" ];
}
