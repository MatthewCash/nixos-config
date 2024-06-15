{ tailscaleId, ... }:

{
    services.tailscale.enable = true;

    systemd.services.tailscaled.serviceConfig = {
        LogLevelMax = "notice";
        Environment = [
            "TS_DEBUG_FIREWALL_MODE=auto"
        ];
    };

    age.secrets."tailscale-${tailscaleId}" = {
        file = ../secrets/tailscale/${tailscaleId}.age;
        path = "/var/lib/tailscale/tailscaled.state";
    };
}
