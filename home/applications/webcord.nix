{ pkgsStable, pkgsUnstable, stableLib, lib, useImpermanence, persistenceHomePath, name, config, ... }:

let
    webcordConfig = {
        settings = {
            general = {
                menuBar = {
                    hide = true;
                };
                tray = {
                    disable = false;
                };
                taskbar = {
                    flash = true;
                };
                window = {
                    transparent = true;
                    hideOnClose = false;
                };
            };
            privacy = {
                blockApi = {
                    science = true;
                    typingIndicator = true;
                    fingerprinting = true;
                };
                permissions= {
                    video = true;
                    audio = true;
                    fullscreen = true;
                    notifications = true;
                    display-capture = true;
                    background-sync = false;
                };
            };
            advanced = {
                csp = {
                    enabled = true;
                };
                cspThirdParty = {
                    spotify = true;
                    gif = true;
                    hcaptcha = true;
                    youtube = true;
                    twitter = true;
                    twitch = true;
                    streamable = true;
                    vimeo = true;
                    soundcloud = true;
                    paypal = true;
                    audius = true;
                    algolia = true;
                    reddit = true;
                    googleStorageApi = true;
                };
                currentInstance = {
                    radio = 0;
                };
                devel = {
                    enabled = false;
                };
                redirection = {
                    warn = true;
                };
                optimize = {
                    gpu = true;
                };
                webApi = {
                    webGl = true;
                };
                unix = {
                    autoscroll = true;
                };
            };
        };
        update = {
            notification = {
                version = "";
                till = "";
            };
        };
        screenShareStore = {
            audio = false;
        };
    };

    configFile = pkgsStable.writeText "config.json" (builtins.toJSON webcordConfig);
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".config/WebCord"
    ];

    home.activation.webcordConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${pkgsUnstable.coreutils}/bin/install -m=644 ${configFile} ${config.xdg.configHome}/WebCord/config.json
    '';


    home.packages = with pkgsUnstable; [ webcord ];
}
