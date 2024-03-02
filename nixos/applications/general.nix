{ pkgsStable, ... }:

{
    environment.systemPackages = with pkgsStable; [
        killall
        file
        gawk
    ];
}
