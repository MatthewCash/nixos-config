{ pkgsUnstable, ... }:

{
    services.xserver = {
        enable = true;

        displayManager = {
            defaultSession = "plasmawayland";
            sddm = {
                enable = true;
                autoNumlock = true;
                theme = "Sweet";
                settings.Theme.ThemeDir = "${pkgsUnstable.sweet-nova}/share/sddm/themes";
            };
        };
        
        desktopManager.plasma5.enable = true;

        libinput.enable = true;

        excludePackages = with pkgsUnstable; [ xterm ];
    };

    environment.plasma5.excludePackages = with pkgsUnstable.plasma5Packages; [
        plasma-browser-integration
        konsole
        oxygen
    ];

    users.extraUsers.sddm.extraGroups = [ "video" ];

    programs.dconf.enable = true;

    services.dbus.packages = with pkgsUnstable; [ dconf ];

    xdg.portal.extraPortals = with pkgsUnstable; [ xdg-desktop-portal-gtk ];
}
