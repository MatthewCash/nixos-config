{ pkgsStable, ... }:

{
    services.fail2ban = {
        enable = true;
        packageFirewall = pkgsStable.nftables;
        banaction = "nftables-multiport";
        banaction-allports = "nftables-allport";
        maxretry = 5;
    };
}
