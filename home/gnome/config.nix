{ stableLib, useImpermanence, persistenceHomePath, name, lib, ... }:

let
    inherit (lib.hm) gvariant;
    inherit (gvariant) mkUint32;
in

{
    home.persistence."${persistenceHomePath}/${name}".files = stableLib.mkIf useImpermanence [
        ".config/monitors.xml"
    ];

    home.sessionVariables.STATIC_WALLPAPER_PATH = "$HOME/.local/share/backgrounds/current_wallpaper.png";

    dconf.settings = {
        "org/gnome/desktop/interface" = {
            clock-show-seconds = true;
            clock-show-weekday = true;
            font-antialiasing = "grayscale";
            monospace-font-name = "CaskaydiaCove Nerd Font 12";
            show-battery-percentage = true;
            enable-hot-corners = true;
            color-scheme = "prefer-dark";
        };

        "org/gnome/desktop/sound" = {
            allow-volume-above-100-percent = true;
        };

        "org/gnome/desktop/wm/preferences" = {
            focus-mode = "sloppy";
            mouse-button-modifier = "<Alt>";
            resize-with-right-button = true;
        };

        "org/gnome/mutter" = {
            attach-modal-dialogs = true;
            center-new-windows = false;
            dynamic-workspaces = true;
            edge-tiling = true;
            focus-change-on-pointer-rest = true;
            workspaces-only-on-primary = true;
            experimental-features = [ "scale-monitor-framebuffer" ];
        };

        "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
            night-light-schedule-automatic = true;
        };

        "org/gnome/settings-daemon/plugins/power" = {
            idle-dim = false;
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-battery-timeout = 1800;
        };

        "org/gnome/shell" = {
            favorite-apps = [
                "webcord.desktop"
                "chromium-browser.desktop"
                "termius-app.desktop"
                "codium.desktop"
                "firefox.desktop"
                "steam.desktop"
                "org.gnome.Boxes.desktop"
                "org.gnome.Console.desktop"
                "org.gnome.Evolution.desktop"
                "org.gnome.Settings.desktop"
                "org.gnome.Nautilus.desktop"
            ];
            enabled-extensions = [
                "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.co"
                "places-menu@gnome-shell-extensions.gcampax.github.com"
                "user-theme@gnome-shell-extensions.gcampax.github.com"
            ];
            disabled-extensions = [ ];
            welcome-dialog-last-shown-version = "41.4";
            disable-extension-version-validation = true;
        };

        # Meant to be used with https://github.com/MatthewCash/wallpaper-changer
        "org/gnome/desktop/screensaver" = {
            picture-uri = "file:///home/${name}/.local/share/backgrounds/current_wallpaper.png";
        };
        "org/gnome/desktop/background" = {
            picture-uri = "file:///home/${name}/.local/share/backgrounds/current_wallpaper.png";
            picture-uri-dark = "file:///home/${name}/.local/share/backgrounds/current_wallpaper.png";
        };

        "org/gnome/desktop/session" = {
            idle-delay = mkUint32 600;
        };

        "com/belmoussaoui/Authenticator" = {
            keyrings-migrated = true;
        };
    };
}