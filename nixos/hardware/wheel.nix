{ pkgsUnstable, ... }:

let
    wheelScript = name: runtimeInputs: action: pkgsUnstable.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgsUnstable; [ coreutils ] ++ runtimeInputs;
        text = /* bash */ ''
            find_wheel_device() {
                local device description lower

                for device in /sys/bus/usb/devices/*; do
                    [ -f "$device/authorized" ] || continue

                    description=""
                    [ -r "$device/product" ] && description="$description $(< "$device/product")"
                    [ -r "$device/manufacturer" ] && description="$description $(< "$device/manufacturer")"
                    lower="$(printf '%s' "$description" | tr '[:upper:]' '[:lower:]')"

                    case "$lower" in
                        *wheel*)
                            printf '%s\n' "$device"
                            return 0
                            ;;
                    esac
                done

                return 1
            }

            set_authorized() {
                local value="$1"
                local wheel_device auth_file

                wheel_device="$(find_wheel_device)" || {
                    printf 'No USB wheel found.\n' >&2
                    exit 1
                }
                auth_file="$wheel_device/authorized"

                printf '%s\n' "$value" > "$auth_file"
                printf '%s\n' "$wheel_device"
            }

            ${action}
        '';
    };
in

{
    environment.systemPackages = [
        (wheelScript "wheel-enable" [] ''
            set_authorized 1 > /dev/null
            printf 'Wheel enabled.\n'
        '')
        (wheelScript "wheel-disable" [] ''
            set_authorized 0 > /dev/null
            printf 'Wheel disabled.\n'
        '')
        (wheelScript "wheel-reset" [] ''
            wheel_device="$(set_authorized 0)"
            sleep 1
            printf '1\n' > "$wheel_device/authorized"
            printf 'Wheel reset.\n'
        '')
        (wheelScript "hide-wheel" [ pkgsUnstable.bubblewrap ] ''
            if wheel_device="$(find_wheel_device)"; then
                wheel_device="$(readlink -f "$wheel_device")"
            else
                printf 'No USB wheel found; running command unchanged.\n' >&2
                exec "$@"
            fi

            is_wheel_sys_path() {
                local sys_path="$1" sys_real
                [ -e "$sys_path" ] || return 1
                sys_real="$(readlink -f "$sys_path")"

                case "$sys_real" in
                    "$wheel_device"/*) return 0 ;;
                    *) return 1 ;;
                esac
            }

            is_wheel_node() {
                local node="$1" real_device sys_path
                [ -e "$node" ] || return 1
                real_device="$(readlink -f "$node")"

                case "$real_device" in
                    /dev/input/event*|/dev/input/js*) ;;
                    *) return 1 ;;
                esac

                sys_path="/sys/class/input/$(basename "$real_device")"
                is_wheel_sys_path "$sys_path"
            }

            is_wheel_hidraw() {
                local node="$1" real_device sys_path
                [ -e "$node" ] || return 1
                real_device="$(readlink -f "$node")"

                case "$real_device" in
                    /dev/hidraw*) ;;
                    *) return 1 ;;
                esac

                sys_path="/sys/class/hidraw/$(basename "$real_device")"
                is_wheel_sys_path "$sys_path"
            }

            is_wheel_link() {
                local link="$1" target
                [ -L "$link" ] || return 1
                target="$(readlink -f "$link")"
                is_wheel_node "$target" || is_wheel_hidraw "$target"
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
                if ! is_wheel_node "$node"; then
                    bwrap_args+=(--dev-bind "$node" "$node")
                fi
            done

            for node in /dev/hidraw*; do
                [ -e "$node" ] || continue
                if is_wheel_hidraw "$node"; then
                    bwrap_args+=(--ro-bind /dev/null "$node")
                fi
            done

            for link_dir in /dev/input/by-id /dev/input/by-path; do
                [ -d "$link_dir" ] || continue

                for link in "$link_dir"/*; do
                    [ -L "$link" ] || continue
                    if ! is_wheel_link "$link"; then
                        bwrap_args+=(--symlink "$(readlink "$link")" "$link")
                    fi
                done
            done

            exec bwrap "''${bwrap_args[@]}" "$@"
        '')
    ];

    # This is for a Logitech G920
    services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c261", RUN+="${pkgsUnstable.usb-modeswitch}/bin/usb_modeswitch -v 046d -p c261 -m 01 -r 01 -C 03 -M '0f00010142'"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c261|c262", TEST=="authorized", RUN+="${pkgsUnstable.coreutils}/bin/chgrp wheel %S%p/authorized", RUN+="${pkgsUnstable.coreutils}/bin/chmod g+w %S%p/authorized"
    '';
}
