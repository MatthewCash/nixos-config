{ pkgsUnstable, persistenceHomePath, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
        ".config/Termius"
    ];

    home.packages = with pkgsUnstable; [ termius ];
}
