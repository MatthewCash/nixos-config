{ pkgs, ... }:

{
    home.packages = with pkgs.gnomeExtensions; [ bluetooth-quick-connect ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "bluetooth-quick-connect@bjarosze.gmail.com" ];
    
    dconf.settings."org/gnome/shell/extensions/bluetooth-quick-connect" = {
        bluetooth-auto-power-on = true;
        refresh-button-on = true;
        show-battery-icon-on = true;
        show-battery-value-on = true;
    };
}
