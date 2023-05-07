{ pkgsUnstable, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".local/share/prismlauncher"
    ];

    home.packages = with pkgsUnstable; [ prismlauncher ];
}
