{ pkgsUnstable, ... }:

let
    mozaUdevRules = pkgsUnstable.writeTextFile {
        name = "moza-udev-rules";
        destination = "/lib/udev/rules.d/72-moza.rules";
        text = ''
            # MOZA R9/CS wheel control and telemetry access.
            SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", MODE="0660", TAG+="uaccess"
            SUBSYSTEM=="hidraw", ATTRS{idVendor}=="346e", MODE="0660", TAG+="uaccess"
            SUBSYSTEM=="usbmisc", KERNEL=="hiddev*", ATTRS{idVendor}=="346e", MODE="0660", TAG+="uaccess"
            SUBSYSTEM=="usb", ATTR{idVendor}=="346e", MODE="0660", TAG+="uaccess"
        '';
    };

    mozaAcTelemetry = pkgsUnstable.writeShellApplication {
        name = "moza-ac-telemetry";
        runtimeInputs = [ pkgsUnstable.python3 ];
        text = ''
            exec python3 ${./moza-ac-telemetry.py} "$@"
        '';
    };

    simsonnAcShifter = pkgsUnstable.writeShellApplication {
        name = "simsonn-ac-shifter";
        runtimeInputs = [
            (pkgsUnstable.python3.withPackages (ps: [ ps.evdev ]))
        ];
        text = ''
            exec python3 ${./simsonn-ac-shifter.py} "$@"
        '';
    };

    mozaAc = pkgsUnstable.writeShellApplication {
        name = "moza-ac";
        runtimeInputs = [ pkgsUnstable.systemd ];
        text = /* bash */ ''
            set -euo pipefail

            if [ "$#" -eq 0 ]; then
                printf 'Usage in Steam launch options: moza-ac %%command%%\n' >&2
                exit 2
            fi

            systemctl --user restart moza-ac-telemetry.service 2>/dev/null || true

            exec "$@"
        '';
    };

    hideWheel = pkgsUnstable.writeShellApplication {
        name = "hide-wheel";
        runtimeInputs = with pkgsUnstable; [ bubblewrap coreutils ];
        text = /* bash */ ''
            find_moza_base_device() {
                local device vendor product

                for device in /sys/bus/usb/devices/*; do
                    [ -r "$device/idVendor" ] || continue
                    [ -r "$device/idProduct" ] || continue

                    vendor="$(< "$device/idVendor")"
                    product="$(< "$device/idProduct")"

                    if [ "$vendor" = "346e" ] && [ "$product" = "0002" ]; then
                        readlink -f "$device"
                        return 0
                    fi
                done

                return 1
            }

            if moza_base_device="$(find_moza_base_device)"; then
                :
            else
                printf 'No MOZA R9 base found; running command unchanged.\n' >&2
                exec "$@"
            fi

            is_moza_base_sys_path() {
                local sys_path="$1" sys_real
                [ -e "$sys_path" ] || return 1
                sys_real="$(readlink -f "$sys_path")"

                case "$sys_real" in
                    "$moza_base_device"|"$moza_base_device"/*) return 0 ;;
                    *) return 1 ;;
                esac
            }

            is_moza_base_input_node() {
                local node="$1" real_device sys_path
                [ -e "$node" ] || return 1
                real_device="$(readlink -f "$node")"

                case "$real_device" in
                    /dev/input/event*|/dev/input/js*) ;;
                    *) return 1 ;;
                esac

                sys_path="/sys/class/input/$(basename "$real_device")"
                is_moza_base_sys_path "$sys_path"
            }

            is_moza_base_hidraw_node() {
                local node="$1" real_device sys_path
                [ -e "$node" ] || return 1
                real_device="$(readlink -f "$node")"

                case "$real_device" in
                    /dev/hidraw*) ;;
                    *) return 1 ;;
                esac

                sys_path="/sys/class/hidraw/$(basename "$real_device")"
                is_moza_base_sys_path "$sys_path"
            }

            is_moza_base_hiddev_node() {
                local node="$1" real_device sys_path
                [ -e "$node" ] || return 1
                real_device="$(readlink -f "$node")"

                case "$real_device" in
                    /dev/usb/hiddev*) ;;
                    *) return 1 ;;
                esac

                sys_path="/sys/class/usbmisc/$(basename "$real_device")"
                is_moza_base_sys_path "$sys_path"
            }

            is_moza_base_input_link() {
                local link="$1" target
                [ -L "$link" ] || return 1
                target="$(readlink -f "$link")"
                is_moza_base_input_node "$target" || is_moza_base_hidraw_node "$target"
            }

            bwrap_args=(
                --bind / /
                --dev-bind /dev /dev
                --tmpfs /dev/input
                --dir /dev/input/by-id
                --dir /dev/input/by-path
            )

            for node in /dev/input/event* /dev/input/js*; do
                [ -e "$node" ] || continue
                if ! is_moza_base_input_node "$node"; then
                    bwrap_args+=(--dev-bind "$node" "$node")
                fi
            done

            for node in /dev/hidraw*; do
                [ -e "$node" ] || continue
                if is_moza_base_hidraw_node "$node"; then
                    bwrap_args+=(--ro-bind /dev/null "$node")
                fi
            done

            for node in /dev/usb/hiddev*; do
                [ -e "$node" ] || continue
                if is_moza_base_hiddev_node "$node"; then
                    bwrap_args+=(--ro-bind /dev/null "$node")
                fi
            done

            for link_dir in /dev/input/by-id /dev/input/by-path; do
                [ -d "$link_dir" ] || continue

                for link in "$link_dir"/*; do
                    [ -L "$link" ] || continue
                    if ! is_moza_base_input_link "$link"; then
                        bwrap_args+=(--symlink "$(readlink "$link")" "$link")
                    fi
                done
            done

            exec bwrap "''${bwrap_args[@]}" "$@"
        '';
    };
in

{
    hardware.uinput.enable = true;

    environment.systemPackages = [
        hideWheel
        mozaAc
        mozaAcTelemetry
        simsonnAcShifter
    ];

    systemd.user.services = {
        "moza-ac-telemetry" = {
            description = "MOZA Assetto Corsa telemetry bridge";
            wantedBy = [ "default.target" ];
            serviceConfig = {
                ExecStart = "${mozaAcTelemetry}/bin/moza-ac-telemetry";
                Restart = "always";
                RestartSec = "1s";
            };
        };
    };

    systemd.services = {
        "simsonn-ac-shifter" = {
            description = "SIMSONN AC shifter virtual joystick";
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
                ExecStart = "${simsonnAcShifter}/bin/simsonn-ac-shifter --strict --grab --device /dev/input/simsonn-hs-pro-shifter";
                Restart = "always";
                RestartSec = "1s";
            };
        };
    };

    # uaccess ACLs are applied by systemd's 73-seat-late.rules, before extraRules' 99-local.rules.
    services.udev.packages = [ mozaUdevRules ];

    services.udev.extraRules = ''
        # Hide the physical SIMSONN from the user session; expose only the stable uinput proxy.
        SUBSYSTEM=="input", KERNEL=="event*", ATTRS{id/vendor}=="ddfd", ATTRS{id/product}=="6013", MODE="0600", TAG-="uaccess", ENV{LIBINPUT_IGNORE_DEVICE}="1", ENV{ID_INPUT}="", ENV{ID_INPUT_JOYSTICK}="", SYMLINK+="input/simsonn-hs-pro-shifter"
        SUBSYSTEM=="input", KERNEL=="js*", ATTRS{id/vendor}=="ddfd", ATTRS{id/product}=="6013", MODE="0600", TAG-="uaccess", ENV{ID_INPUT}="", ENV{ID_INPUT_JOYSTICK}=""
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="ddfd", ATTRS{idProduct}=="6013", MODE="0600", TAG-="uaccess"
        SUBSYSTEM=="usbmisc", KERNEL=="hiddev*", ATTRS{idVendor}=="ddfd", ATTRS{idProduct}=="6013", MODE="0600", TAG-="uaccess"
        SUBSYSTEM=="usb", ATTR{idVendor}=="ddfd", ATTR{idProduct}=="6013", MODE="0600", TAG-="uaccess"

        # User access for the virtual SIMSONN joystick created by simsonn-ac-shifter.service.
        SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="SIMSONN HS PRO AC Shifter", MODE="0660", TAG+="uaccess", ENV{ID_INPUT}="1", ENV{ID_INPUT_JOYSTICK}="1", SYMLINK+="input/simsonn-ac-shifter"
    '';
}
