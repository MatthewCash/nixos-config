{ pkgsUnstable, inputs, accentColor, config, ... }:

let
    customCss = /* css */ ''
        @define-color accent_bg_color ${accentColor.hex};
        @define-color accent_color ${accentColor.hex};

        :root {
            --accent-color: ${accentColor.hex};
            --accent-bg-color: ${accentColor.hex};
        }
    '';

    shellCssFile = "${inputs.gnome-accent-colors}/custom-accent-colors@demiskp/resources/magenta/gnome-shell/44/gnome-shell.css";
    shellCss = builtins.replaceStrings
        [ "#c061cb" ]
        [ accentColor.hex ]
        (builtins.readFile shellCssFile);
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

    xdg.dataFile."themes/shell-theme/gnome-shell/gnome-shell.css".text = shellCss;
    dconf.settings."org/gnome/shell/extensions/user-theme".name = "shell-theme";

    xdg.configFile."gtk-3.0/gtk.css".text = customCss;
    xdg.configFile."gtk-4.0/gtk.css".text = customCss;
}
