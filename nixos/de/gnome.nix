{ pkgsUnstable, stableLib, ... }:

{
    services.xserver = {
        enable = true;

        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        excludePackages = with pkgsUnstable; [ xterm ];
    };

    services.libinput.enable = true;

    users.extraUsers.gdm.extraGroups = [ "video" ];

    services.gnome = {
        # Do not install default GNOME apps
        core-utilities.enable = false;

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
        QT_STYLE_OVERRIDE = stableLib.mkForce "\${QT_STYLE_OVERRIDE}";
        NIXOS_OZONE_WL = "1";
    };

    programs.dconf.enable = true;

    services.dbus.packages = with pkgsUnstable; [ dconf gcr ];

    services.udev.packages = with pkgsUnstable; [ gnome-settings-daemon ];
}
