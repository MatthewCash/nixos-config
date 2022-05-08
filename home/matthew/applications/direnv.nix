{ persistenceHomePath, name, ... }:
{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        "/home/matthew/.local/share/direnv/allow"
    ];

    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };
}
