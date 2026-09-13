{ persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
        ".ssh"
    ];

    programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
            "*" = {
                IdentitiesOnly = true;
                IdentityFile = [ "~/.ssh/id_${name}" ];
            };
        };
    };
}
