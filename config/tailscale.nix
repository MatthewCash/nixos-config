{ config, tailscaleId, vpnAddress, ... }:

{
    services.tailscale = {
        enable = true;
    };

    age.secrets."tailscale-${tailscaleId}" = {
        file = ../secrets/tailscale/${tailscaleId}.age;
        path = "/var/lib/tailscale/tailscaled.state";
    };
}
