{ pkgs, ... }:

let
    bluez = pkgs.bluez.overrideAttrs (oldAttrs: rec {
        version = "5.63";
        src = pkgs.fetchurl {
            url = "mirror://kernel/linux/bluetooth/${oldAttrs.pname}-${version}.tar.xz";
            sha256 = "sha256-k0nhHoFguz1yCDXScSUNinQk02kPUonm22/gfMZsbXY=";
        };
    });
in

{
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;

        media-session.enable = false;
        wireplumber.enable = true;
    };

    hardware.pulseaudio.enable = false;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = bluez;
}
