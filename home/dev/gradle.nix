{ persistenceHomePath, config, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
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
