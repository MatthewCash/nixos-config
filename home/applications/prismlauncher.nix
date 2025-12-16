{ pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".local/share/PrismLauncher"
    ];

    home.packages = with pkgsUnstable; [ prismlauncher ];
}
