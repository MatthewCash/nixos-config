{ pkgsUnstable, persistenceHomePath, name, config, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".local/share/.npm"
        ".cache/.npm-global"
        ".cache/typescript"
    ];

    home.sessionVariables = {
        NODE_REPL_HISTORY = "${config.xdg.cacheHome}/node/repl_history";
        NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    };

    home.packages = with pkgsUnstable; with nodePackages; [
        nodejs
        npm
        typescript
    ];

    xdg.configFile."npm/npmrc".text = ''
        prefix=${config.xdg.dataHome}/npm
        cache=${config.xdg.cacheHome}/npm
        tmp=${config.xdg.dataHome}/npm
        init-module=${config.xdg.configHome}/npm/config/npm-init.js
    '';
}
