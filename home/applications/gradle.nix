{ pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, config, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".config/gradle/cache"
        ".config/gradle/wrapper"
    ];

    home.sessionVariables.GRADLE_USER_HOME = "${config.xdg.configHome}/gradle";

    home.packages = with pkgsUnstable; [ gradle ];
}
