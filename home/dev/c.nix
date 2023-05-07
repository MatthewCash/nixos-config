{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [
        gcc
        gdb
        gnumake
        binutils
    ];
}
