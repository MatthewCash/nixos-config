{ pkgs, ... }:

{
    services.fail2ban = {
        enable = true;
        packageFirewall = pkgs.nftables;
        banaction = "nftables-multiport";
        banaction-allports = "nftables-allport";
        maxretry = 5;
    };
}
