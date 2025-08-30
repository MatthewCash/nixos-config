{ pkgsUnstable, ... }:

{
    services.displayManager = {
        defaultSession = "plasma";
        sddm = {
            enable = true;
            wayland.enable = true;
            autoNumlock = true;
            theme = "Sweet";
            settings.Theme.ThemeDir = "${pkgsUnstable.sweet-nova}/share/sddm/themes";
        };
    };

    services.libinput.enable = true;

    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgsUnstable.kdePackages; [
        plasma-browser-integration
        konsole
        oxygen
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.dconf.enable = true;

    services.dbus.packages = with pkgsUnstable; [ dconf ];

    xdg.portal.extraPortals = with pkgsUnstable; [ xdg-desktop-portal-gtk ];
}
