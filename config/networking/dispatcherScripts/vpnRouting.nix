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
                home_net_id_hash="997ae2dff5a617f2bafa6ae7ffe50b8594265de06894a5b5f24590d3dea58761"
                current_net_id_hash=$(echo "$CONNECTION_ID" | ${pkgs.coreutils}/bin/sha256sum | sed 's/ .*$//')

                # Remove previous DNAT rules
                ${pkgs.nftables}/bin/nft flush chain ip nat zero

                # Remove VPN routing rules
                ${pkgs.iproute2}/bin/ip route flush table wg_vpn

                if [[ "$current_net_id_hash" = "$home_net_id_hash" ]]; then
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
    ];
}
