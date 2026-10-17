{ pkgsUnstable, ... }:

{
    services.displayManager.plasma-login-manager.enable = true;

    services.desktopManager.plasma6.enable = true;

    systemd.user.services.drkonqi-coredump-pickup.enable = false;

    environment.plasma6.excludePackages = with pkgsUnstable.kdePackages; [
        plasma-browser-integration
        konsole
        oxygen
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
