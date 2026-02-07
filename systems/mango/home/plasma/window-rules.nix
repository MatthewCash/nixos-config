{ ... }:

{
    programs.plasma.window-rules = [
        {
            description = "Hide titlebar for Minecraft";
            match.window-class = {
                value = "Minecraft";
                type = "substring";
                match-whole = false;
            };
            apply = {
                maximizehoriz = true;
                maximizevert = true;
                noborder = true;
            };
        }
        {
            description = "Hide titlebar for Minecraft (AxolotlClient)";
            match.window-class = {
                value = "AxolotlClient";
                type = "substring";
                match-whole = false;
            };
            apply = {
                maximizehoriz = true;
                maximizevert = true;
                noborder = true;
            };
        }
        {
            description = "Position Vesktop Personal";
            match.window-class = {
                value = "com.discord.vesktop.personal";
                match-whole = false;
            };
            apply = {
                position = "4485,9";
                size = "1907,1067";
                ignoregeometry = true;
            };
        }
        {
            description = "Position Vesktop Business";
            match.window-class = {
                value = "com.discord.vesktop.business";
                match-whole = false;
            };
            apply = {
                position = "4485,1085";
                size = "1907,1067";
                ignoregeometry = true;
            };
        }
    ];
}
