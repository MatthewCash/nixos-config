{ pkgsUnstable, ... }:

let
    vmpkConfig = (pkgsUnstable.formats.ini {}).generate "vmpk-piano.conf" {
        Connections = {
            AdvancedEnabled = true;
            InEnabled = true;
            InPort = "SMK25V2";
            InputDriver = "ALSA";
            OutPort = "smk25";
            OutputDriver = "ALSA";
            ThruEnabled = false;
        };

        Preferences = {
            InstrumentName = "Acoustic Grand Piano";
            NumKeys = 88;
        };
    };

    python = pkgsUnstable.python3.withPackages (pythonPackages: with pythonPackages; [
        evdev
        python-rtmidi
    ]);

    piano = pkgsUnstable.writeShellApplication {
        name = "piano";
        runtimeInputs = with pkgsUnstable; [ coreutils gnugrep gnused vmpk ];
        text = ''
            config="''${XDG_CONFIG_HOME:-$HOME/.config}/vmpk/piano.conf"
            mkdir -p "$(dirname "$config")"

            if [ ! -e "$config" ]; then
                install -m 600 ${vmpkConfig} "$config"
            fi

            set_connection() {
                local key="$1"
                local value="$2"

                if grep -q "^$key=" "$config"; then
                    sed -i "s/^$key=.*/$key=$value/" "$config"
                else
                    sed -i "/^\[Connections\]$/a\\$key=$value" "$config"
                fi
            }

            set_connection AdvancedEnabled true
            set_connection InEnabled true
            set_connection InputDriver ALSA
            set_connection InPort SMK25V2
            set_connection OutputDriver ALSA
            set_connection OutPort smk25
            set_connection ThruEnabled false

            ${pkgsUnstable.systemd}/bin/systemctl --user start piano-smk25.service piano-autolink.service piano-shifter.service || true
            exec vmpk --portable --file "$config"
        '';
    };

    piano-shifter = pkgsUnstable.writeShellApplication {
        name = "piano-shifter";
        runtimeInputs = [ python ];
        text = ''
            exec python ${./piano-shifter.py} "$@"
        '';
    };

    piano-autolink = pkgsUnstable.writeShellApplication {
        name = "piano-autolink";
        runtimeInputs = with pkgsUnstable; [ alsa-utils coreutils gnugrep pipewire ];
        text = ''
            find_output() {
                pw-link --output | grep -E -m 1 "$1" || true
            }

            find_input() {
                pw-link --input | grep -E -m 1 "$1" || true
            }

            ensure_link() {
                local from="$1"
                local to="$2"

                if [ -n "$from" ] && [ -n "$to" ]; then
                    pw-link "$from" "$to" 2>/dev/null || true
                fi
            }

            remove_link() {
                local from="$1"
                local to="$2"

                if [ -n "$from" ] && [ -n "$to" ]; then
                    pw-link -d "$from" "$to" 2>/dev/null || true
                fi
            }

            ensure_alsa_link() {
                local from="$1"
                local to="$2"

                aconnect "$from" "$to" 2>/dev/null || true
            }

            ensure_links() {
                local piano_fl piano_fr vmpk_fl vmpk_fr speaker_l speaker_r media_l media_r

                piano_fl="$(find_output '^smk25:(left|l_00|out_0|output_FL|playback_FL|FL)$')"
                piano_fr="$(find_output '^smk25:(right|r_00|out_1|output_FR|playback_FR|FR)$')"
                vmpk_fl="$(find_output '^SonivoxEAS:output_FL$')"
                vmpk_fr="$(find_output '^SonivoxEAS:output_FR$')"
                speaker_l="$(find_input '^alsa_output\.pci-0000_00_1f\.3\.analog-stereo:playback_FL$')"
                speaker_r="$(find_input '^alsa_output\.pci-0000_00_1f\.3\.analog-stereo:playback_FR$')"
                media_l="$(find_input '^media:(input|playback)_FL$')"
                media_r="$(find_input '^media:(input|playback)_FR$')"

                ensure_link "$piano_fl" "$speaker_l"
                ensure_link "$piano_fr" "$speaker_r"
                ensure_link "$vmpk_fl" "$speaker_l"
                ensure_link "$vmpk_fr" "$speaker_r"
                remove_link "$piano_fl" "$media_l"
                remove_link "$piano_fr" "$media_r"
                remove_link "$vmpk_fl" "$media_l"
                remove_link "$vmpk_fr" "$media_r"
                ensure_alsa_link "SMK25V2:0" "VMPK Input:0"
                ensure_alsa_link "SMK25V2:0" "smk25:0"
                ensure_alsa_link "VMPK Output:0" "smk25:0"
            }

            while true; do
                ensure_links
                sleep 1
            done
        '';
    };
in

{
    home.packages = [
        piano
        pkgsUnstable.vmpk
    ];

    systemd.user.services.piano-smk25 = {
        Unit = {
            Description = "smk25 piano synthesizer";
            Requires = [ "pipewire.service" "wireplumber.service" ];
            After = [ "pipewire.service" "wireplumber.service" ];
            PartOf = [ "pipewire.service" ];
        };

        Service = {
            ExecStart = "${pkgsUnstable.pipewire.jack}/bin/pw-jack ${pkgsUnstable.fluidsynth}/bin/fluidsynth -i -s -a jack -m alsa_seq -p smk25 -o audio.jack.id=smk25 -o audio.jack.autoconnect=false -o midi.alsa_seq.id=smk25 -o midi.autoconnect=false -o synth.gain=0.6 ${pkgsUnstable.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";
            Restart = "always";
            RestartSec = 1;
        };

        Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.piano-autolink = {
        Unit = {
            Description = "Auto-link smk25 piano output to the speakers";
            Requires = [ "piano-smk25.service" ];
            After = [ "pipewire.service" "wireplumber.service" "piano-smk25.service" ];
            PartOf = [ "pipewire.service" ];
        };

        Service = {
            ExecStart = "${piano-autolink}/bin/piano-autolink";
            Restart = "always";
            RestartSec = 1;
        };

        Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.piano-shifter = {
        Unit = {
            Description = "Map SIMSONN shifter positions to smk25 piano programs";
            # Bound crash-loop construction rate so a sequencer outage
            # degrades to slow retries instead of a client-creation storm.
            StartLimitIntervalSec = 60;
            StartLimitBurst = 5;
            Requires = [ "piano-smk25.service" ];
            After = [ "pipewire.service" "wireplumber.service" "piano-smk25.service" ];
            PartOf = [ "pipewire.service" ];
        };

        Service = {
            ExecStart = "${piano-shifter}/bin/piano-shifter";
            Restart = "always";
            RestartSec = 5;
        };

        Install.WantedBy = [ "default.target" ];
    };
}
