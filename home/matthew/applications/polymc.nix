{ pkgs, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".local/share/polymc"
    ];

    home.packages = with pkgs; [ polymc ];
}
