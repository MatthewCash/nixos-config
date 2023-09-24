{ ... }:

{
    # Disable IPTables
    networking.firewall.enable = false;

    networking.nftables.enable = true;
}
