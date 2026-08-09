{ pkgsUnstable, stableLib, accentColor, ... }:

let
    shellCss = pkgsUnstable.runCommand "gnome-shell-system-css" { } /* bash */ ''
        ${pkgsUnstable.glib.dev}/bin/gresource extract \
            ${pkgsUnstable.gnome-shell}/share/gnome-shell/gnome-shell-theme.gresource \
            /org/gnome/shell/theme/gnome-shell-dark.css \
        | sed 's/-st-accent-color/${accentColor.hex}/g' \
        > $out
    '';
    shellResourceOverlay = "/org/gnome/shell/theme/gnome-shell-dark.css=${shellCss}";
in

{
    services = {
        displayManager.gdm.enable = true;
        displayManager.generic.environment.G_RESOURCE_OVERLAYS = shellResourceOverlay;
        desktopManager.gnome.enable = true;
    };

    services.libinput.enable = true;

    users.extraUsers.gdm.extraGroups = [ "video" ];

    services.gnome = {
        core-apps.enable = false;
        gnome-keyring.enable = true;
        gnome-browser-connector.enable = true;
        gnome-settings-daemon.enable = true;
    };

    environment.gnome.excludePackages = with pkgsUnstable; [ gnome-tour ];

    # GDM UX Settings
    programs.dconf.profiles.gdm.databases = [{
        settings = {
            "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
            "org/gnome/desktop/input-sources".xkb-options = [ "caps:escape" ];
            "org/gnome/desktop/interface".show-battery-percentage = true;
                "org/gnome/desktop/peripherals/touchpad" = {
                tap-to-click = true;
                two-finger-scrolling-enabled = true;
                    click-method = "areas";
                natural-scroll = true;
                send-events = "enabled";
                speed = 0.6;
            };
        };
    }];

    environment.sessionVariables = {
        G_RESOURCE_OVERLAYS = shellResourceOverlay;
        QT_STYLE_OVERRIDE = stableLib.mkForce "\${QT_STYLE_OVERRIDE}";
        NIXOS_OZONE_WL = "1";
    };

    programs.dconf.enable = true;

    services.dbus.packages = with pkgsUnstable; [ dconf gcr ];

    services.udev.packages = with pkgsUnstable; [ gnome-settings-daemon ];
}
