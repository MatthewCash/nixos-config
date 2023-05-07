{ stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".local/share/direnv/allow"
    ];

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };
}
