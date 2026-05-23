{ persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
        ".ssh"
    ];

    programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
            "github.com" = {
                IdentitiesOnly = true;
                IdentityFile = [ "~/.ssh/id_git" ];
            };
            "*" = {
                IdentitiesOnly = true;
                IdentityFile = [ "~/.ssh/id_${name}" ];
            };
        };
    };
}
