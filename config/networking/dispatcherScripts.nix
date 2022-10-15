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
            type = "pre-up";
            source = pkgs.writeText "upHook" ''
                home_net_id="NETZ_5"
                current_net_id="$CONNECTION_ID"
                
                # Remove previous DNAT rules
                ${pkgs.nftables}/bin/nft flush chain ip nat zero
                
                # Remove VPN routing rules
                ${pkgs.iproute2}/bin/ip route flush table wg_vpn

                if [[ "$current_net_id" = "$home_net_id" ]]; then
                    # Add DNAT rules pointing to LAN
                    ${pkgs.nftables}/bin/nft add rule ip nat zero ip daddr 172.30.0.2 counter dnat to 192.168.1.211
                    ${pkgs.nftables}/bin/nft add rule ip nat zero ip daddr 172.30.0.5 counter dnat to 192.168.1.203
                else
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
