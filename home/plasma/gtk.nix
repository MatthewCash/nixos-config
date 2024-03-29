{ pkgsUnstable, config, ... }:

{
    gtk = {
        enable = false;

        cursorTheme = {
            package = pkgsUnstable.libsForQt5.breeze-qt5;
            name = "breeze_cursors";
        };

        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
    };
}
