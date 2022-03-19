{ pkgs, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/Termius"
    ];

    home.packages = with pkgs; [ termius ];
}
