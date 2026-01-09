{ stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}".directories = stableLib.mkIf useImpermanence [
        ".ssh"
    ];

    programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
            github = {
                host = "github.com";
                identitiesOnly = true;
                identityFile = [ "~/.ssh/id_git" ];
            };
            all = {
                host = "*";
                identitiesOnly = true;
                identityFile = [ "~/.ssh/id_${name}" ];
            };
        };
    };
}
