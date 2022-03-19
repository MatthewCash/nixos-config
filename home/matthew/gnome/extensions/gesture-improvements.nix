{ pkgs, ... }:

{   
    home.packages = with pkgs.gnomeExtensions; [ gesture-improvements ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "gestureImprovements@gestures" ];

    dconf.settings."org/gnome/shell/extensions/gestureImprovements" = {
        allow-minimize-window = true;
        default-overview = true;
        default-session-workspace = true;
        enable-alttab-gesture = false;
        follow-natural-scroll = true;
        touchpad-speed-scale = 0.65;
    };
}
