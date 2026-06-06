{ pkgsUnstable, ... }:

let
    python = pkgsUnstable.python3.withPackages (pythonPackages: with pythonPackages; [
        pulsectl
        pyside6
    ]);

    channel-mixer = pkgsUnstable.writeShellApplication {
        name = "channel-mixer";
        runtimeInputs = [ python ];
        text = ''
            exec python ${./pw-bus-dials.py} "$@"
        '';
    };
in

{
    home.packages = [ channel-mixer ];

    xdg.dataFile."icons/hicolor/scalable/apps/channel-mixer.svg".source = ./channel-mixer.svg;

    xdg.desktopEntries.channel-mixer = {
        name = "Channel Mixer";
        comment = "Control PipeWire audio bus volumes";
        exec = "channel-mixer";
        icon = "channel-mixer";
        terminal = false;
        categories = [ "Audio" "Mixer" ];
    };
}
