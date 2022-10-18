{ pkgs, inputs, system, ... }:

let
    customCss = ''
        @define-color accent_bg_color #e77be0;
        @define-color accent_color @accent_bg_color;
    '';
in

{
    gtk = {
        enable = true;

        theme = {
            package = pkgs.adw-gtk3;
            name = "adw-gtk3-dark";
        };

        iconTheme = {
            package = pkgs.kora-icon-theme;
            name = "kora";
        };

        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
    };

    xdg.configFile."gtk-3.0/gtk.css".text = customCss;
    xdg.configFile."gtk-4.0/gtk.css".text = customCss;
}
