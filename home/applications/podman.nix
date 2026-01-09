{ pkgsUnstable, persistenceHomePath, ... }:

{
    home.persistence."${persistenceHomePath}".files = [
        ".local/share/containers/storage"
    ];

    home.packages = with pkgsUnstable; [ podman podman-compose ];
}
