{ pkgsUnstable, config, ... }:

{
    gtk = {
        enable = false;

        theme = {
            package = pkgsUnstable.kdePackages.breeze-gtk;
            name = "Breeze-Dark";
        };

        cursorTheme = {
            package = pkgsUnstable.kdePackages.breeze;
            name = "breeze_cursors";
        };

        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
    };
}
