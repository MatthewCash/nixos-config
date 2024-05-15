{ stableLib, useImpermanence, persistenceHomePath, name, config, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".config/gradle/cache"
        ".config/gradle/wrapper"
    ];

    programs.gradle = {
        enable = true;
        home = "${config.xdg.configHome}/gradle";
        settings = {
            "org.gradle.caching" = true;
            "org.gradle.parallel" = true;
            "org.gradle.home" = config.programs.java.package;
        };
    };
}
