{ pkgsUnstable, pkgsStable, accentColor, config, ... }:

let
    customCss = /* css */ ''
        @define-color accent_bg_color ${accentColor.hex};
        @define-color accent_color ${accentColor.hex};

        :root {
            --accent-color: ${accentColor.hex};
            --accent-bg-color: ${accentColor.hex};
        }
    '';

    oldShellCss = pkgsStable.runCommand "gnome-shell-css" { } /* bash */ ''
        ${pkgsUnstable.glib.dev}/bin/gresource \
             extract \
            ${pkgsUnstable.gnome-shell}/share/gnome-shell/gnome-shell-theme.gresource \
            /org/gnome/shell/theme/gnome-shell-dark.css \
        > $out
    '';

    shellCss = builtins.replaceStrings
        [ "-st-accent-color" ]
        [ accentColor.hex ]
        (builtins.readFile oldShellCss);
in

{
    gtk = {
        enable = true;

        theme = {
            package = pkgsUnstable.adw-gtk3;
            name = "adw-gtk3-dark";
        };

        iconTheme = {
            package = pkgsUnstable.kora-icon-theme;
            name = "kora";
        };

        cursorTheme = {
            package = pkgsUnstable.adwaita-icon-theme;
            name = "Adwaita";
        };

        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
    };

    home.packages = with pkgsUnstable.gnomeExtensions; [ user-themes ];
    xdg.dataFile."themes/shell-theme/gnome-shell/gnome-shell.css".text = shellCss;
    dconf.settings = {
        "org/gnome/shell".enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" ];
        "org/gnome/shell/extensions/user-theme".name = "shell-theme";
    };

    xdg.configFile."gtk-3.0/gtk.css".text = customCss;
    xdg.configFile."gtk-4.0/gtk.css".text = customCss;
}
