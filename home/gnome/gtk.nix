{ pkgsUnstable, pkgsStable, accentColor, config, ... }:

let
    shellCss = pkgsStable.runCommand "gnome-shell-css" { } /* bash */ ''
        ${pkgsUnstable.glib.dev}/bin/gresource \
            extract \
            ${pkgsUnstable.gnome-shell}/share/gnome-shell/gnome-shell-theme.gresource \
            /org/gnome/shell/theme/gnome-shell-dark.css \
        | sed s/-st-accent-color/${accentColor.hex}/g\
        > $out
    '';
in

{
    gtk = {
        enable = true;

        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

        gtk3 = {
            theme = {
                package = pkgsUnstable.adw-gtk3;
                name = "adw-gtk3-dark";
            };

            extraConfig.gtk-application-prefer-dark-theme = 1;

            extraCss = /* css */ ''
                @define-color accent_bg_color ${accentColor.hex};
                @define-color accent_color ${accentColor.hex};
            '';
        };

        gtk4.extraCss = /* css */ ''
            :root {
                --accent-bg-color: ${accentColor.hex};
            }
        '';

        iconTheme = {
            package = pkgsUnstable.kora-icon-theme;
            name = "kora";
        };

        cursorTheme = {
            package = pkgsUnstable.adwaita-icon-theme;
            name = "Adwaita";
        };
    };

    home.packages = with pkgsUnstable.gnomeExtensions; [ user-themes ];
    xdg.dataFile."themes/shell-theme/gnome-shell/gnome-shell.css".source = shellCss;
    dconf.settings = {
        "org/gnome/shell".enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" ];
        "org/gnome/shell/extensions/user-theme".name = "shell-theme";
    };
}
