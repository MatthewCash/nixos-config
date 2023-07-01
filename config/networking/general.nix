{ stableLib, hostname, ... }:

{
    networking.hostName = hostname;

    systemd.services.NetworkManager-wait-online.enable = stableLib.mkForce false;
}
