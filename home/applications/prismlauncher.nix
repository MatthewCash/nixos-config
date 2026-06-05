{ pkgsStable, pkgsUnstable, stableLib, persistenceHomePath, inputs, ... }:

let
    wrappedPrismlauncher = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; } {
        config = { sloth, ... }: {
            app.package = pkgsUnstable.prismlauncher;
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.freedesktop.Notifications" = "talk";
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            flatpak.session-helper.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bind.rw = [
                    (sloth.concat' sloth.xdgDataHome "/PrismLauncher")
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    [(sloth.concat' sloth.xdgDataHome "/PrismLauncher/tmp") "/tmp"]
                    (sloth.concat' sloth.xdgStateHome "/nix/profile/share/Kvantum")
                    (sloth.concat' sloth.xdgStateHome "/nix/profile/lib/qt-6/plugins")
                    (sloth.concat' sloth.xdgConfigHome "/Kvantum")
                ];
                bind.ro = [
                    "/run/current-system"
                    "/etc/fonts"
                ];
                sockets = {
                    wayland = true;
                    x11 = true; # mc instances don't work quite right with wayland yet
                    pipewire = true;
                    pulse = true;
                };
                env.PATH = "${pkgsUnstable.jdk}/bin/";
            };
        };
    };

    muteMinecraftWhenUnfocused = pkgsUnstable.writeShellApplication {
        name = "mute-minecraft-when-unfocused";
        runtimeInputs = with pkgsUnstable; [
            kdotool
            pulseaudio
        ];
        text = ''
            set_minecraft_mute() {
                local muted="$1"
                local current_id=""
                local is_java=false
                local is_game=false

                flush_input() {
                    if [[ -n "$current_id" && "$is_java" == true && "$is_game" == true ]]; then
                        pactl set-sink-input-mute "$current_id" "$muted" || true
                    fi
                }

                while IFS= read -r line; do
                    if [[ "$line" == Sink\ Input\ \#* ]]; then
                        flush_input
                        current_id="''${line#Sink Input #}"
                        is_java=false
                        is_game=false
                        continue
                    fi

                    case "$line" in
                        *'node.name = "java"'*) is_java=true ;;
                        *'application.process.binary = "java"'*) is_java=true ;;
                        *'media.role = "game"'*) is_game=true ;;
                        *'media.role = "Game"'*) is_game=true ;;
                    esac
                done < <(pactl list sink-inputs)

                flush_input
            }

            while true; do
                class="$(kdotool getactivewindow getwindowclassname 2>/dev/null || true)"

                if [[ "$class" == *Minecraft* || "$class" == *AxolotlClient* ]]; then
                    muted=false
                else
                    muted=true
                fi

                set_minecraft_mute "$muted"
                sleep 0.5
            done
        '';
    };
in

{
    home.persistence."${persistenceHomePath}".directories = [
        ".local/share/PrismLauncher"
    ];

    home.packages = [ wrappedPrismlauncher.config.env ];

    xdg.desktopEntries.prismlauncher-enderscale = {
        name = "Enderscale Creative";
        comment = "Launch Minecraft via Prism Launcher and join Enderscale Creative";
        exec = "prismlauncher -l Modern -s creative.coral.zero --show-window";
        terminal = false;
        categories = [ "Game" ];
    };

    systemd.user.services.mute-minecraft-when-unfocused = {
        Unit = {
            Description = "Mute Minecraft when it is not focused";
            After = [ "graphical-session.target" "pipewire-pulse.service" ];
            PartOf = [ "graphical-session.target" ];
        };

        Service = {
            ExecStart = "${muteMinecraftWhenUnfocused}/bin/mute-minecraft-when-unfocused";
            Restart = "always";
            RestartSec = 1;
        };

        Install.WantedBy = [ "graphical-session.target" ];
    };
}
