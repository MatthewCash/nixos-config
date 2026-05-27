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

        extraConfig.pipewire."92-low-latency" = {
            "context.properties" = {
                "default.clock.rate" = 48000;  # Fixed rate avoids resampling latency
                "default.clock.quantum" = 128;      # ~5ms latency at 48kHz
                "default.clock.min-quantum" = 64;   # ~2.5ms latency at 48kHz
                "default.clock.max-quantum" = 512;
            };
        };

        extraConfig.pipewire-pulse."92-low-latency" = {
            "pulse.properties" = {
                "pulse.min.req" = "64/48000";    # Start with 64, not 32, for stability
                "pulse.default.req" = "64/48000";
                "pulse.max.req" = "128/48000";
            };
        };
    };

    services.pulseaudio.enable = false;
}
