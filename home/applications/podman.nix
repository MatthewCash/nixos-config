{ pkgsUnstable, persistenceHomePath, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
        ".local/share/containers/storage"
    ];

    home.packages = with pkgsUnstable; [ podman podman-compose ];
}
