{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ just-perfection ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "just-perfection-desktop@just-perfection" ];

    dconf.settings."org/gnome/shell/extensions/just-perfection" = {
        search = false;
        acitivities-button = true;
        support-notifier-type = 0;
    };
}
