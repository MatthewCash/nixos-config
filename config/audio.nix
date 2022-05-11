{ ... }:

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
}
