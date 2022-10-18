{ pkgs, ... }:

{
    virtualisation.hypervGuest.enable = true;

    boot.kernelModules = [ "vhci_hcd" ];

    boot.kernelParams = [ "nomodeset" ];

    services.xserver = {
        videoDrivers = [ "fbdev" ];
    };
}
