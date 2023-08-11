{ pkgsStable, ... }:

{
    environment.systemPackages = with pkgsStable; [
        wget
        killall
        pciutils
        tcpdump
        htop
        file
        gawk
    ];
}
