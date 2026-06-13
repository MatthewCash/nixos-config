{ ... }:

{
    # Limit "A stop job is running..." delay
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

    systemd.user.settings.Manager.DefaultTimeoutStopSec = "10s";
}
