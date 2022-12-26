{ ... }:

{
    # Limit "A stop job is running..." delay
    systemd.extraConfig = ''
        DefaultTimeoutStopSec=10s
    '';
    systemd.user.extraConfig = ''
        DefaultTimeoutStopSec=10s
    '';
}
