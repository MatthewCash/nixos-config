{ stableLib, useImpermanence, persistenceHomePath, name, config, ... }:

{
    programs.gpg = {
        enable = true;
        homedir = "${config.xdg.configHome}/gnupg";
    };

    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".config/gnupg"
    ];

    services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        pinentryFlavor = "gnome3";
    };
}
