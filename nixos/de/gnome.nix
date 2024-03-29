{ pkgsUnstable, stableLib, stateVersion, ... }:

{
    services.xserver = {
        enable = true;

        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        libinput.enable = true;

        excludePackages = with pkgsUnstable; [ xterm ];
    };

    users.extraUsers.gdm.extraGroups = [ "video" ];

    services.gnome = {
        # Do not install default GNOME apps
        core-utilities.enable = false;

        gnome-keyring.enable = true;

        gnome-browser-connector.enable = true;

        gnome-settings-daemon.enable = true;
    };

    environment.gnome.excludePackages = with pkgsUnstable; [ gnome-tour ];

    # Setup /run/gdm directory
    systemd.tmpfiles.rules = [ "d /run/gdm 0711 gdm gdm -" ];

    # GDM UX Settings
    home-manager.users.gdm.home.stateVersion = stateVersion;
    home-manager.users.gdm.dconf.settings = {
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
        "org/gnome/desktop/input-sources".xkb-options = [ "caps:escape" ];
        "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
            two-finger-scrolling-enabled = true;
            click-method = "areas";
            natural-scroll = true;
            send-events = "enabled";
            speed = 0.6;
        };
    };

    environment.sessionVariables = {
        QT_STYLE_OVERRIDE = stableLib.mkForce "$QT_STYLE_OVERRIDE";
        NIXOS_OZONE_WL = "1";
    };

    programs.dconf.enable = true;

    services.dbus.packages = with pkgsUnstable; [ dconf gcr ];

    services.udev.packages = with pkgsUnstable; [ gnome.gnome-settings-daemon ];
}
