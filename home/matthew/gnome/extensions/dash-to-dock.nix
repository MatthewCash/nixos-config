{ pkgs, ... }:

let
    dash-to-dock = pkgs.gnomeExtensions.dash-to-dock.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
            owner = "micheleg";
            repo = "dash-to-dock";
            rev = "9c59e7e586be71588f177644127e6179c8b86ebe";
            sha256 = "sha256-ej2ZI3h7l/vmeIwFnwcMFL3VNbeGZtwkB91b+Wg9YuU=";
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
