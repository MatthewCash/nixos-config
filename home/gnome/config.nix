{ stableLib, lib, systemConfig, config, ... }:

let
    inherit (lib.hm) gvariant;
    inherit (gvariant) mkUint32;

    wallpaperPath = "${config.xdg.dataHome}/backgrounds/current_wallpaper";
in

{
    home.sessionVariables.STATIC_WALLPAPER_PATH = wallpaperPath;

    xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/http" = stableLib.mkForce [ "org.mozilla.Firefox.gnome.desktop" ];
        "x-scheme-handler/https" = stableLib.mkForce [ "org.mozilla.Firefox.gnome.desktop" ];
        "application/pdf" = stableLib.mkForce [ "org.mozilla.Firefox.gnome.desktop" ];
    };

    dconf.settings = {
        "org/gnome/desktop/interface" = {
            clock-show-seconds = true;
            clock-show-weekday = true;
            font-antialiasing = "grayscale";
            monospace-font-name = stableLib.mkIf (systemConfig != null)
                "${builtins.head systemConfig.fonts.fontconfig.defaultFonts.monospace} 12";
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

        "org/gnome/settings-daemon/plugins/power" = {
            idle-dim = false;
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-battery-timeout = 1800;
        };

        "org/gnome/shell" = {
            favorite-apps = [
                "org.discord.webcord.personal.desktop"
                "org.discord.webcord.business.desktop"
                "org.google.chromium.desktop"
                "termius-app.desktop"
                "codium.desktop"
                "org.mozilla.Firefox.gnome.desktop"
                "steam.desktop"
                "org.gnome.Boxes.desktop"
                "org.gnome.Console.desktop"
                "org.gnome.Evolution.desktop"
                "org.gnome.Settings.desktop"
                "org.gnome.Nautilus.desktop"
            ];
            enabled-extensions = [
                "places-menu@gnome-shell-extensions.gcampax.github.com"
                "user-theme@gnome-shell-extensions.gcampax.github.com"
            ];
            disabled-extensions = [ ];
            disable-extension-version-validation = true;
        };

        # Meant to be used with https://github.com/MatthewCash/wallpaper-changer
        "org/gnome/desktop/screensaver" = {
            picture-uri = "file://${wallpaperPath}";
        };
        "org/gnome/desktop/background" = {
            picture-uri = "file://${wallpaperPath}";
            picture-uri-dark = "file://${wallpaperPath}";
        };

        "org/gnome/desktop/session" = {
            idle-delay = mkUint32 600;
        };

        "com/belmoussaoui/Authenticator" = {
            keyrings-migrated = true;
        };

        # USBGuard integration (see config/hardware/usbguard.nix)
        "org/gnome/desktop/privacy" = {
            usb-protection = true;
            usb-protection-level = "lockscreen";
        };
    };
}
