{ pkgs, ... }:

let
    adw-gtk3-theme = pkgs.callPackage ./adw-gtk3-theme.nix { };
in

{   
    gtk = {
        enable = true;

        theme = { 
            package = adw-gtk3-theme;
            name = "adw-gtk3-dark";
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
