{ ... }:

{
    # Limit "A stop job is running..." delay
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

    systemd.user.extraConfig = /* ini */ ''
        DefaultTimeoutStopSec=10s
    '';
}
