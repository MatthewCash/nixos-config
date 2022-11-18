{ pkgsUnstable, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".npm"
        ".npm-global"
        ".cache/typescript"
    ];

    home.packages = with pkgsUnstable; with nodePackages; [
        npm
        typescript
    ];
}
