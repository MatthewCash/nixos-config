{ persistenceHomePath, name, ... }:

{
    programs.gpg.enable = true;

    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".gnupg"
    ];

    services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
    };
}
