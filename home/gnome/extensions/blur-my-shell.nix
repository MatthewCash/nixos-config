{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ blur-my-shell ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "blur-my-shell@aunetx" ];

    dconf.settings."org/gnome/shell/extensions/blur-my-shell/panel" = {
        override-background-dynamically = true;
    };
}
