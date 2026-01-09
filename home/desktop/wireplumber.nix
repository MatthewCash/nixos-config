{ persistenceHomePath, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
        ".local/state/wireplumber"
    ];
}
