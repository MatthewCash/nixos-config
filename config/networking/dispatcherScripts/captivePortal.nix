{ pkgsStable, ... }:

{
    networking.networkmanager.dispatcherScripts = [
        {
            type = "basic";
            source = pkgsStable.writeText "upHook" /* bash */ ''
                school_net_id_hash="91648cf7c1626c2cfc05948221c7a1c46a139589f3ca809c44b6dd4bd31b5a7a"
                current_net_id_hash=$(echo "$CONNECTION_ID" | ${pkgsStable.coreutils}/bin/sha256sum | sed 's/ .*$//')

                if [[ "$NM_DISPATCHER_ACTION" = "up" && "$current_net_id_hash" = "$school_net_id_hash" ]]; then
                    # Complete captive portal
                    ${pkgsStable.curl}/bin/curl -m 10 -d "originurl=http://%3a%2f%2f172%2e16%2e8%2e131%2f" http://172.16.8.131/forms/guest_toued || true
                fi
            '';
        }
    ];
}
