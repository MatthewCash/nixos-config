{ pkgsStable, stableLib, vpnAddress, config, ... }:

{
    age.secrets."wireguard-privatekey-${vpnAddress}".file = ../../../secrets/wireguard/${vpnAddress}/privkey.age;

    networking.wg-quick.interfaces = {
        wg0 = {
            address = [ "${vpnAddress}/32" ];
            peers = [
                {
                    allowedIPs = [ "0.0.0.0/0" ];
                    endpoint = "matthew-cash.com:51820";
                    publicKey = "CKvBr7B5OGUStsZy0FXWgyYPsy28Yx5/kAw1WHWXCFI=";
                    persistentKeepalive = 25;
                }
            ];
            table = "off";
            privateKeyFile = config.age.secrets."wireguard-privatekey-${vpnAddress}".path;
            postUp = let ip = stableLib.getExe' pkgsStable.iproute2 "ip"; in /* bash */ ''
                ${ip} route add 10.0.0.0/24 via ${vpnAddress}
                ${ip} rule add to 172.30.0.0/24 table wg_vpn
            '';
        };
    };
}
