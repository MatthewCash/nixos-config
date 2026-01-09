{ pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}".directories = stableLib.mkIf useImpermanence [
        ".config/Termius"
    ];

    home.packages = with pkgsUnstable; [ termius ];
}
