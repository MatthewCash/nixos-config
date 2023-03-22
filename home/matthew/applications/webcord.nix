{ pkgsStable, pkgsUnstable, persistenceHomePath, name, ... }:

let
    config = {
        settings = {
            general = {
                menuBar = {
                    hide = true;
                };
                tray = {
                    disable = false;
                };
                taskbar= {
                    flash = true;
                };
                window= {
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
            advanced= {
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
                gpu = false;
            };
            webApi = {
                webGl = true;
            };
            unix = {
                autoscroll = true;
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
};

    configFile = pkgsStable.writeText "config.json" (builtins.toJSON config);
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/WebCord"
    ];

    home.file.".config/WebCord/config.json".source = configFile;

    home.packages = with pkgsUnstable; [ webcord ];
}
