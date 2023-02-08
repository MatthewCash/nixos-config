{ pkgsUnstable, pkgsStable, inputs, system, ... }:

let
    customCss = ''
        @define-color accent_bg_color #e77be0;
        @define-color accent_color @accent_bg_color;
    '';

    shellCssFile = "${inputs.gnome-accent-colors}/custom-accent-colors@demiskp/resources/magenta/gnome-shell/gnome-shell.css";
    shellCss = builtins.replaceStrings
        [ "#c061cb" ]
        [ "#e085e0" ]
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

        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
    };

    home.file.".local/share/themes/shell-theme/gnome-shell/gnome-shell.css".text = shellCss;
    dconf.settings."org/gnome/shell/extensions/user-theme".name = "shell-theme";

    xdg.configFile."gtk-3.0/gtk.css".text = customCss;
    xdg.configFile."gtk-4.0/gtk.css".text = customCss;
}
