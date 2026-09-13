{ ... }:

{
    security.rtkit.enable = true;

    security.pam.loginLimits = [
        { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
        { domain = "@audio"; item = "rtprio"; type = "-"; value = "95"; }
    ];

    boot.kernelParams = [
        "threadirqs"
        "preempt=full"
    ];

    services.pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;
    };

    services.pulseaudio.enable = false;
}
