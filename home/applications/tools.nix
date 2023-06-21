{ pkgsUnstable, ... }:

{
    # A collection of simple command-line tools that do not have any large runtimes
    # Anything with configuration/persistence should get its own config file
    
    home.packages = with pkgsUnstable; [
        coreutils-full
        binutils
        nano
        iproute2
        zip
        unzip
        p7zip
        ripgrep
        ripgrep-all
        gnutar
        gnused
        gawk
        tree
    ];
}
