{ pkgsUnstable, ... }:

let
    audio-bus-volume = pkgsUnstable.writeShellApplication {
        name = "audio-bus-volume";
        runtimeInputs = with pkgsUnstable; [ pulseaudio util-linux ];
        text = ''
            lock="''${XDG_RUNTIME_DIR:-/tmp}/audio-bus-volume.lock"
            exec flock "$lock" pactl "$@"
        '';
    };
in

{
    _module.args.steamLaunchEnv = {
        PULSE_SINK = "games";
    };

    _module.args.prismlauncherBubblewrapEnv = {
        PIPEWIRE_NODE = "games";
        PULSE_SINK = "games";
    };

    programs.plasma.shortcuts.kmix = {
        decrease_volume = [ ];
        decrease_volume_small = [ ];
        increase_volume = [ ];
        increase_volume_small = [ ];
        mute = [ ];
    };

    programs.plasma.hotkeys.commands = {
        decrease-media-volume = {
            name = "Decrease Media Volume";
            comment = "Decrease Media Volume";
            key = "Volume Down";
            command = "${audio-bus-volume}/bin/audio-bus-volume set-sink-volume media -1%";
            logs.enabled = false;
        };

        increase-media-volume = {
            name = "Increase Media Volume";
            comment = "Increase Media Volume";
            key = "Volume Up";
            command = "${audio-bus-volume}/bin/audio-bus-volume set-sink-volume media +1%";
            logs.enabled = false;
        };

        mute-media-volume = {
            name = "Mute Media Volume";
            comment = "Mute Media Volume";
            key = "Volume Mute";
            command = "${audio-bus-volume}/bin/audio-bus-volume set-sink-mute media toggle";
            logs.enabled = false;
        };
    };
}
