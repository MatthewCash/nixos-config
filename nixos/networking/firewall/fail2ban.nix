{ pkgsStable, ... }:

{
    services.fail2ban = {
        enable = true;
        packageFirewall = pkgsStable.nftables;
        maxretry = 5;
    };
}
