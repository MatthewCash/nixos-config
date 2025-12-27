{ stableLib, lib, pkgsStable, pkgsUnstable, systemConfig, config, persistenceHomePath, name, useImpermanence, ... }:

let
    inherit (lib.hm) gvariant;
    inherit (gvariant) mkUint32;

    wallpaperPath = "${config.xdg.dataHome}/backgrounds/current_wallpaper";

    monitorsSyncScript = pkgsStable.writeShellScript "gnome-monitors-config-sync" /* sh */ ''
        SRC="${config.xdg.configHome}/monitors.xml"
        DEST="${persistenceHomePath}/${name}/.config/monitors.xml"
        ${stableLib.getExe' pkgsStable.coreutils "cp"} "$DEST" "$SRC"

        ${stableLib.getExe' pkgsStable.inotify-tools "inotifywait"} -m "$(dirname "$SRC")" |
            while read -r path event filename; do
                if [[ "$filename" == "$(basename "$SRC")" && "$event" == "CLOSE_WRITE,CLOSE" ]]; then
                    ${stableLib.getExe' pkgsStable.coreutils "cp"} --preserve=mode,timestamps "$SRC" "$DEST"
                fi
            done
    '';
in

{
    home.packages = with pkgsUnstable; [ pinentry-gnome3 ];

    systemd.user.services.gnome-monitors-config-sync = stableLib.mkIf useImpermanence {
        Unit = {
            Description = "Sync gnome monitors.xml to persistent config";
            Before = "gnome-session-manager@gnome.service";
        };
        Install.WantedBy = [ "graphical-session-pre.target" ];
        Service = {
            ExecStart = "${stableLib.getExe pkgsStable.bash} ${monitorsSyncScript}";
        };
    };

    home.sessionVariables.STATIC_WALLPAPER_PATH = wallpaperPath;

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

        "org/gnome/settings-daemon/plugins/media-keys" = {
            volume-step = 3;
        };

        "org/gnome/settings-daemon/plugins/housekeeping" = {
            donation-reminder-enabled = false;
        };

        "org/gnome/shell" = {
            enabled-extensions = [
                "places-menu@gnome-shell-extensions.gcampax.github.com"
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
