{ stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".ssh"
    ];

    programs.ssh = {
        enable = true;
        matchBlocks = {
            github = {
                host = "github.com";
                identitiesOnly = true;
                identityFile = [ "~/.ssh/id_git" ];
            };
            all = {
                host = "*";
                identitiesOnly = true;
                identityFile = [ "~/.ssh/id_matthew" ];
                extraOptions = {
                    GSSAPIAuthentication = "no";
                };
            };
        };
    };
}
