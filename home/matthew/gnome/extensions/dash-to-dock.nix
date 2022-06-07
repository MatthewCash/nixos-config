{ pkgs, ... }:

{   
    home.packages = with pkgs.gnomeExtensions; [ dash-to-dock ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];

    dconf.settings."org/gnome/shell/extensions/dash-to-dock" = {
        apply-custom-theme = false;
        background-opacity = 0.30;
        custom-background-color = false;
        custom-theme-shrink = false;
        dash-max-icon-size = 54;
        dock-position = "BOTTOM";
        extend-height = false;
        force-straight-corner = false;
        height-fraction = 0.9;
        icon-size-fixed = false;
        isolate-monitors = false;
        isolate-workspaces = false;
        middle-click-action = "launch";
        multi-monitor = false;
        preferred-monitor = 0;
        preview-size-scale = 0.0;
        scroll-action = "cycle-windows";
        shift-click-action = "minimize";
        shift-middle-click-action = "launch";
        show-favorites = true;
        transparency-mode = "FIXED";
    };
}
