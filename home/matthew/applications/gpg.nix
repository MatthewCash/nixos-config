{ persistenceHomePath, name, config, ... }:

{
    programs.gpg = {
        enable = true;
        homedir = "${config.xdg.configHome}/gnupg";
    };

    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/gnupg"
    ];

    services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
    };
}
