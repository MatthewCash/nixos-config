{ pkgs, ... }:

{   
    gtk = {
        enable = true;

        theme = { 
            package = pkgs.orchis-theme;
            name = "Orchis-dark";
        };

        iconTheme = {
            package = pkgs.kora-icon-theme;
            name = "kora";
        };

        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
    };
}
