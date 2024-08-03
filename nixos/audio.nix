{ ... }:

{
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;
    };

    hardware.pulseaudio.enable = false;
}
