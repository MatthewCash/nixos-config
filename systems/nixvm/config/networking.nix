{ ... }:

let
    systemAddress = "192.168.40.2";
    netmask = 24;
    gatewayAddress = "192.168.40.1";
in

{
    networking = {
        hosts = {
            "${gatewayAddress}" = [ "host" "windows" "inferno" ];
        };

        nameservers = [ "192.168.1.201" "1.1.1.1" ]; 

        interfaces = {
            eth0.ipv4.addresses = [{
                address = systemAddress;
                prefixLength = netmask;
            }];
        };

        defaultGateway = gatewayAddress;
    };
}
