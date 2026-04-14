{ persistenceHomePath, name, ... }:

let
    persistHome = "${persistenceHomePath}home/${name}";
in

{
    xdg.userDirs = {
        enable = true;
        setSessionVariables = true;

        documents = "${persistHome}/documents";
        download = "${persistHome}/downloads";
        music = "${persistHome}/music";
        pictures = "${persistHome}/pictures";
        videos = "${persistHome}/videos";
    };

    home.persistence.${persistenceHomePath}.directories = [
        "code"
        "documents"
        "downloads"
        "music"
        "pictures"
        "videos"
    ];
}
