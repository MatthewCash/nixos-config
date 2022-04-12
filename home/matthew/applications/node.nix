{ pkgs, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".npm"
        ".npm-global"
        ".cache/typescript"
    ];

    home.packages = with pkgs; with nodePackages; [
        npm
        typescript
    ];
}
