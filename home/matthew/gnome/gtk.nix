{ pkgs, inputs, system, ... }:

let
    customCss = ''
        @define-color accent_color #ff0000;
        
        @define-color accent_bg_color #00ff00;
        
        @define-color window_bg_color #282a36;
        
        @define-color window_fg_color #f8f8f2;
        
        @define-color headerbar_bg_color #282a36;
        
        @define-color headerbar_fg_color #f8f8f2;
        
        @define-color popover_bg_color #282a36;
        
        @define-color popover_fg_color #f8f8f2;
        
        @define-color view_bg_color #282a36;
        
        @define-color view_fg_color #f8f8f2;
        
        @define-color card_bg_color rgba(255, 255, 255, 0.08);
        
        @define-color card_fg_color #f8f8f2;
    '';
in

{   
    gtk = {
        enable = true;

        theme = { 
            package = inputs.adw-gtk3.defaultPackage.${system};
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
        
    xdg.configFile."gtk-3.0/gtk.css".text = customCss;
    xdg.configFile."gtk-4.0/gtk.css".text = customCss;
}
