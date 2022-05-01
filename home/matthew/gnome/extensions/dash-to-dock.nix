{ pkgs, ... }:

let
    dash-to-dock = pkgs.gnomeExtensions.dash-to-dock.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
            owner = "micheleg";
            repo = "dash-to-dock";
            rev = "d3783824840c969f4990e1bd2a1b56517bddb73c";
            sha256 = "sha256-opR0nSnWeZf+CO7R0HriIlzg83Wmqdzt/CmFZBEpK8E=";
        };
    });
in

{   
    home.packages = [ dash-to-dock ];

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
