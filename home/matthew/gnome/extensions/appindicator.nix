{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ appindicator ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];
}
