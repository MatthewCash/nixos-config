{ ... }:

let
    systemAddress = "192.168.40.2";
    prefixLength = 24;
    gatewayAddress = "192.168.40.1";
in

{
    networking = {
        hosts = {
            "${gatewayAddress}" = [ "host" "windows" "inferno" ];
        };

        nameservers = [ "100.100.100.100" "1.1.1.1" ];
        resolvconf.extraOptions = [ "use-vc" ];

        interfaces.eth0.ipv4.addresses = [{
            inherit prefixLength;
            address = systemAddress;
        }];

        defaultGateway = gatewayAddress;
    };
}
