{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ space-bar ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "space-bar@luchrioh" ];
}
