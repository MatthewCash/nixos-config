{ pkgsUnstable, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".gradle/cache"
        ".gradle/wrapper"
    ];

    home.packages = with pkgsUnstable; [ gradle ];
}
