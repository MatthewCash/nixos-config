{ pkgs, ... }:

{
    services.xserver = {
        enable = true;

        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;

        libinput.enable = true;
    };

    services.gnome = {
        # Do not install default GNOME apps
        core-utilities.enable = false;

        gnome-keyring.enable = true;

        chrome-gnome-shell.enable = true;
    };

    programs.dconf.enable = true;
    
    services.dbus.packages = with pkgs; [ dconf gcr ];
    
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
