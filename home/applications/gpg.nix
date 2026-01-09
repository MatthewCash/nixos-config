{ pkgsUnstable, persistenceHomePath, config, ... }:

{
    programs.gpg = {
        enable = true;
        homedir = "${config.xdg.configHome}/gnupg";
    };

    home.persistence."${persistenceHomePath}".directories = [
        ".config/gnupg"
    ];

    services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        pinentry.package = pkgsUnstable.pinentry-gnome3;
    };
}
