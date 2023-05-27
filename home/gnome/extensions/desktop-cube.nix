{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ desktop-cube ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "desktop-cube@schneegans.github.com" ];
}
