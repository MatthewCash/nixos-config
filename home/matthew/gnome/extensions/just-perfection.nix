{ pkgs, ... }:

{   
    home.packages = with pkgs.gnomeExtensions; [ just-perfection ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "just-perfection-desktop@just-perfection" ];

    dconf.settings."org/gnome/shell/extensions/just-perfection" = {
        search = false;
        acitivities-button = true;
    };
}
