{ pkgsUnstable, ... }:

let
    pactl = "${pkgsUnstable.pulseaudio}/bin/pactl";
in

{
    xdg.desktopEntries.plasma-manager-commands.startupNotify = false;

    programs.plasma.shortcuts = {
        kmix = {
            decrease_volume = [ ];
            decrease_volume_small = [ ];
            increase_volume = [ ];
            increase_volume_small = [ ];
            mute = [ ];
        };
        kwin."Window Close" = ["Alt+F4" "Meta+Q"];
        plasmashell."manage activities" = [ ];
    };

    programs.plasma.hotkeys.commands = {
        decrease-media-volume = {
            name = "Decrease Media Volume";
            comment = "Decrease Media Volume";
            key = "Volume Down";
            command = "${pactl} set-sink-volume media -1%";
            logs.enabled = false;
        };

        increase-media-volume = {
            name = "Increase Media Volume";
            comment = "Increase Media Volume";
            key = "Volume Up";
            command = "${pactl} set-sink-volume media +1%";
            logs.enabled = false;
        };

        mute-media-volume = {
            name = "Mute Media Volume";
            comment = "Mute Media Volume";
            key = "Volume Mute";
            command = "${pactl} set-sink-mute media toggle";
            logs.enabled = false;
        };
    };
}
