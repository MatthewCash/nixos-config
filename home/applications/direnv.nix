{ stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}".directories = stableLib.mkIf useImpermanence [
        ".local/share/direnv/allow"
    ];

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };
}
