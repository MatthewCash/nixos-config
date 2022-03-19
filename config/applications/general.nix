{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        vim
        wget
        killall
        pciutils
        tcpdump
        htop
        file
        oathToolkit
        gawk
    ];
}
