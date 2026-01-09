{ stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}".directories = stableLib.mkIf useImpermanence [
        ".local/state/wireplumber"
    ];
}
