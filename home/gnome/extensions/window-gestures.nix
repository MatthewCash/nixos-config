{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ window-gestures ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "windowgestures@extension.amarullz.com" ];

    dconf.settings."org/gnome/shell/extensions/windowgestures" = {
        taphold-move = false;
        swipe4-updown = 1;
    };
}
