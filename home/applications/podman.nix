{ pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}" = stableLib.mkIf useImpermanence {
        files = [ ".local/share/containers/storage" ];
    };

    home.packages = with pkgsUnstable; [ podman podman-compose ];
}
