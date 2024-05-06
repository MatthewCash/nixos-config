{ pkgsUnstable, config, ... }:

{
    home.packages = with pkgsUnstable; [ wget wget2 ];

    home.sessionVariables.WGETRC = "${config.xdg.configHome}/wgetrc";

    xdg.configFile."wgetrc".text = /* ini */ ''
        hsts-file = ${config.xdg.cacheHome}/wget-hsts
    '';
}
