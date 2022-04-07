{ pkgs, ... }:

let
    kora-icon-theme = pkgs.kora-icon-theme.overrideAttrs(oldAttrs: {
        src = pkgs.fetchFromGitHub {
            owner = "bikass";
            repo = "kora";
            rev = "af092d2e99b4fb8f83f37bf8ddc5acae43bb36dc";
            sha256 = "sha256-uNQlKginkEim5kRX/aesKyvGyCb/wDRD2GCjJsOMRB4=";
        };
    });

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
            package = kora-icon-theme;
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
