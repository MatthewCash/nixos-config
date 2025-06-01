{ persistPath, ... }:

{
    environment.persistence.${persistPath}.files = [ "/var/lib/tailscale/tailscaled.state" ];

    services.tailscale.enable = true;

    systemd.services.tailscaled.serviceConfig = {
        LogLevelMax = "notice";
        Environment = [
            "TS_DEBUG_FIREWALL_MODE=auto"
        ];
    };
}
