{ pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".gradle/cache"
        ".gradle/wrapper"
    ];

    home.packages = with pkgsUnstable; [ gradle ];
}
