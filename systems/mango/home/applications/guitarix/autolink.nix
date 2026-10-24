{ pkgsUnstable }:

pkgsUnstable.writeShellApplication {
    name = "guitarix-autolink";
    runtimeInputs = with pkgsUnstable; [
        gnugrep
        pipewire
    ];
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

        ensure_links() {
            local guitar_in gx_in gx_out_l gx_out_r speaker_l speaker_r

            guitar_in="$(find_output '^alsa_input\.usb-BurrBrown_from_Texas_Instruments_USB_AUDIO_CODEC-00\..*:capture_FR$')"
            gx_in="$(find_input '^gx_head_amp:in_0$')"

            gx_out_l="$(find_output '^gx_head_fx:out_0$')"
            gx_out_r="$(find_output '^gx_head_fx:out_1$')"
            speaker_l="$(find_input '^alsa_output\.pci-0000_00_1f\.3\.analog-stereo:playback_FL$')"
            speaker_r="$(find_input '^alsa_output\.pci-0000_00_1f\.3\.analog-stereo:playback_FR$')"
            ensure_link "$guitar_in" "$gx_in"
            ensure_link "$gx_out_l" "$speaker_l"
            ensure_link "$gx_out_r" "$speaker_r"
        }

        ensure_links

        pw-link --links --monitor | while read -r _; do
            ensure_links
        done
    '';
}
