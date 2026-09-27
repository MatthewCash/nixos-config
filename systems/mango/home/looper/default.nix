{ pkgsUnstable, ... }:

let
    python = pkgsUnstable.python3.withPackages (pythonPackages: with pythonPackages; [
        pyside6
    ]);

    looper = pkgsUnstable.writeShellApplication {
        name = "looper";
        runtimeInputs = with pkgsUnstable; [ pipewire pipewire.jack sooperlooper python ];
        text = ''
            exec pw-jack python ${./looper.py} "$@"
        '';
    };
in

{
    home.packages = [ looper ];

    xdg.dataFile."icons/hicolor/scalable/apps/looper.svg".source = ./looper.svg;

    xdg.desktopEntries.looper = {
        name = "Looper";
        comment = "Loop piano and guitar audio";
        exec = "looper";
        icon = "looper";
        terminal = false;
        categories = [ "Audio" "AudioVideo" "Music" ];
    };
}
