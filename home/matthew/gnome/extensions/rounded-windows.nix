{ pkgs, ... }:

{
    home.packages = with pkgs.gnomeExtensions; [ rounded-window-corners ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "rounded-window-corners@yilozt" ];
}
