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
                "default.clock.rate" = 48000;       # Fixed rate avoids resampling latency
                "default.clock.quantum" = 128;      # 2.67ms processing period at 48kHz
                "default.clock.min-quantum" = 64;   # 1.33ms processing period at 48kHz
                "default.clock.max-quantum" = 512;
            };
        };
    };

    services.pulseaudio.enable = false;
}
