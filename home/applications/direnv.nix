{ persistenceHomePath, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
        ".local/share/direnv/allow"
    ];

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };
}
