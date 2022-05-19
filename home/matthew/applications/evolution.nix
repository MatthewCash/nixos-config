{ persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".local/share/evolution"
        ".config/evolution"
        ".cache/evolution"
    ];

    dconf.settings."org/gnome/evolution/mail" = {
        layout = 1;
        show-to-do-bar = false;
        show-to-do-bar-sub = false;
        mark-seen-timeout = 0;
    };

    dconf.settings."org/gnome/evolution/mail/browser-window" = {
        height = 400;
        width = 600;
        maximized = false;
    };

    dconf.settings."org/gnome/evolution/mail/composer-window" = {
        height = 800;
        width = 1150;
        show-to-do-bar = false;
        show-to-do-bar-sub = false;
        maximized = false;
    };

    dconf.settings."org/gnome/evolution/shell" = {
        attachment-view = 0;
        autoar-filter = "none";
        autoar-format = "zip";
        buttons-visible = true;
        buttons-visible-sub = true;
        default-component-id = "mail";
        folder-bar-width = 263;
        folder-bar-width-sub = 259;
        menubar-visible = false;
        menubar-visible-sub = false;
        sidebar-visible = true;
        sidebar-visible-sub = true;
        statusbar-visible = false;
        statusbar-visible-sub = true;
        toolbar-visible = true;
        toolbar-visible-sub = true;
    };

    dconf.settings."org/gnome/evolution/shell/window" = {
        height = 1080;
        maximized = false;
        width = 1920;
        x = 0;
        y = 0;
    };
}
