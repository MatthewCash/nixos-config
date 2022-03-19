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
    };
}
