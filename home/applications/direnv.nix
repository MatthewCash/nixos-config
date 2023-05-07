{ persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".local/share/direnv/allow"
    ];

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };
}
