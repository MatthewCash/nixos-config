{ persistenceHomePath, config, ... }:

{
    programs.gpg = {
        enable = true;
        homedir = "${config.xdg.configHome}/gnupg";
    };

    home.persistence."${persistenceHomePath}".directories = [
        {
            directory = ".config/gnupg";
            mode = "0700";
        }
    ];

    services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        enableZshIntegration = true;
        # pinentry.package is set in de config
    };
}
