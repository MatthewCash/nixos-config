{ ... }:

let
    systemAddress = "192.168.40.2/24";
    gatewayAddress = "192.168.40.1";
in

{
    networking = {
        useDHCP = false;
        hosts.${gatewayAddress} = [ "host" ];
        nameservers = [ "100.100.100.100" "1.1.1.1" ];
    };

    systemd.network.enable = true;

    systemd.network.networks."20-hyperswitch" = {
        matchConfig.Name = "eth0";
        address = [ systemAddress ];
        routes = [ { Gateway = gatewayAddress; } ];
    };
}
