{ pkgsStable, pkgsUnstable, persistenceHomePath, name, ... }:

let
    discordConfig = {
        BACKGROUND_COLOR = "#202225";
        IS_MAXIMIZED = false;
        IS_MINIMIZED = true;
        WINDOW_BOUNDS = {
            x = 91;
            y = 230;
            width = 1280;
            height = 720;
        };
        SKIP_HOST_UPDATE = true;
    };

    discordConfigFile = pkgsStable.writeText "settings.json" (builtins.toJSON discordConfig);
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/discord"
    ];

    home.file.".config/discord/settings.json".source = discordConfigFile;

    home.packages = with pkgsUnstable; [ discord ];
}
