{ pkgsUnstable, ... }:

{
    services.displayManager = {
        defaultSession = "plasma";
        plasma-login-manager.enable = true;
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
