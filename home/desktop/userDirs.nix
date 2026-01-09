{ persistenceHomePath, name, ... }:

let
    persistHome = "${persistenceHomePath}/${name}";
in

{
    xdg.userDirs = {
        enable = true;

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
