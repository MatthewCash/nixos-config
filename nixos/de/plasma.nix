{ pkgsUnstable, ... }:

{
    services.displayManager.plasma-login-manager.enable = true;

    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgsUnstable.kdePackages; [
        plasma-browser-integration
        konsole
        oxygen
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
