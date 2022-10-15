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
        }
        {
            type = "basic";
            source = pkgs.writeText "upHook" ''
                school_net_uuid="eb7d4c15-44f1-4649-83a7-fce78ed236c5"
                current_net_uuid="$CONNECTION_UUID"

                if [[ "$NM_DISPATCHER_ACTION" = "up" && "$current_net_uuid" = "$school_net_uuid" ]]; then
                    # Complete captive portal
                    ${pkgs.curl}/bin/curl -m 10 -d "originurl=http://%3a%2f%2f172%2e16%2e8%2e131%2f" http://172.16.8.131/forms/guest_toued || true
                fi
            '';
        }
    ];
}
