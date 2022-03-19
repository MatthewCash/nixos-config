{ pkgs, ... }:

{
    networking.iproute2 = {
        enable = true;
        rttablesExtraConfig = ''
            120     wg_vpn
        '';
    };

    networking.networkmanager.dispatcherScripts = [
        {
            source = pkgs.writeText "upHook" ''
                home_net_id="NETZ"
                current_net_id="$CONNECTION_ID"

                if [[ "$current_net_id" = "$home_net_id" ]]; then
                    # Remove previous DNAT rules
                    ${pkgs.nftables}/bin/nft flush chain ip nat zero

                    # Add DNAT rules pointing to LAN
                    ${pkgs.nftables}/bin/nft add rule ip nat zero ip daddr 172.30.0.2 counter dnat to 192.168.1.201
                    ${pkgs.nftables}/bin/nft add rule ip nat zero ip daddr 172.30.0.5 counter dnat to 192.168.1.203

                    # Remove VPN routing rules
                    ${pkgs.iproute2}/bin/ip route flush table wg_vpn
                else
                    # Remove previous DNAT rules
                    ${pkgs.nftables}/bin/nft flush chain ip nat zero

                    # Add DNAT rules pointing to VPN
                    ${pkgs.nftables}/bin/nft add rule ip nat zero ip daddr 172.30.0.2 counter dnat to 10.0.0.2
                    ${pkgs.nftables}/bin/nft add rule ip nat zero ip daddr 172.30.0.5 counter dnat to 10.0.0.5

                    # Add VPN routing rules
                    ${pkgs.iproute2}/bin/ip route add 172.30.0.2 via 10.0.0.9 table wg_vpn
                    ${pkgs.iproute2}/bin/ip route add 172.30.0.5 via 10.0.0.9 table wg_vpn
                fi
            '';
            type = "pre-up";
        }
    ];
}
