{ persistPath, ... }:

{
    environment.persistence.${persistPath}.files = [ "/var/lib/tailscale/tailscaled.state" ];

    services.tailscale = {
        enable = true;
        disableUpstreamLogging = true;
        extraDaemonFlags = [ "--encrypt-state=false" ];
    };

    systemd.services.tailscaled.serviceConfig = {
        LogLevelMax = "notice";
        Environment = [
            "TS_DEBUG_FIREWALL_MODE=auto"
        ];
    };
}
