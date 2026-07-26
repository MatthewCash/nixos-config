{ pkgsUnstable, ... }:

let
    speaker = "alsa_output.pci-0000_00_1f.3.analog-stereo";

    mkBus = name: description: extraSinkProperties: {
        name = "libpipewire-module-loopback";
        args = {
            "node.description" = description;
            "audio.position" = [ "FL" "FR" ];
            "capture.props" = {
                "node.name" = name;
                "media.class" = "Audio/Sink";
            } // extraSinkProperties;
            "playback.props" = {
                "node.name" = "${name}-bus-speaker-loopback";
                "target.object" = speaker;
                "node.dont-move" = true;
                "node.dont-reconnect" = true;
                "node.passive" = true;
                "stream.dont-remix" = true;
            };
        };
    };

    pipewireAudioBusConfig = {
        "context.modules" = [
            (mkBus "voice" "Voice" { })
            (mkBus "games" "Games" { "device.intended-roles" = "Game game"; })
            (mkBus "media" "Media" { })
        ];
    };

    audio-bus-volume = pkgsUnstable.writeShellApplication {
        name = "audio-bus-volume";
        runtimeInputs = with pkgsUnstable; [ pulseaudio util-linux ];
        text = ''
            lock="''${XDG_RUNTIME_DIR:-/tmp}/audio-bus-volume.lock"
            exec flock "$lock" pactl "$@"
        '';
    };

    forceMediaDefaultScript = ''
        local om = ObjectManager {
            Interest {
                type = "metadata",
                Constraint { "metadata.name", "=", "default" },
            }
        }
        om:connect("object-added", function(_, metadata)
            metadata:set(0, "default.configured.audio.sink", "Spa:String:JSON",
                Json.Object { ["name"] = "media" }:to_string())
        end)
        om:activate()
    '';

    routeGameStreamsScript = ''
        lutils = require("linking-utils")
        cutils = require("common-utils")
        log = Log.open_topic("s-linking")

        local function prop(props, name)
            return tostring(props[name] or ""):lower()
        end

        local function proc_has_arg(pid_info, needle)
            for i = 0, pid_info:get_n_args() - 1, 1 do
                local arg = pid_info:get_arg(i)
                if arg ~= nil and tostring(arg):find(needle, 1, true) ~= nil then
                    return true
                end
            end

            return false
        end

        local function is_steam_launched_process(pid)
            local curr_pid = tonumber(pid)
            local depth = 0

            while curr_pid ~= nil and curr_pid > 1 and depth < 32 do
                local ok, pid_info = pcall(ProcUtils.get_proc_info, curr_pid)
                if not ok or pid_info == nil then
                    return false
                end

                if proc_has_arg(pid_info, "SteamLaunch") and proc_has_arg(pid_info, "AppId=") then
                    return true
                end

                curr_pid = pid_info:get_parent_pid()
                depth = depth + 1
            end

            return false
        end

        local function is_game_stream(props)
            local role = prop(props, "media.role")
            if role == "game" then
                return true
            end

            local app_name = prop(props, "application.name")
            local app_id = prop(props, "application.id")
            local binary = prop(props, "application.process.binary")
            local node_name = prop(props, "node.name")
            local pid = props["application.process.id"]

            return app_name == "steam"
                or app_name == "steamwebhelper"
                or app_name == "ac linux manager"
                or app_id == "com.valvesoftware.steam"
                or app_id == "ac-linux-manager"
                or binary == "ac-linux-manager"
                or binary == "steam"
                or binary == "steamwebhelper"
                or node_name:find("steam", 1, true) ~= nil
                or is_steam_launched_process(pid)
        end

        SimpleEventHook {
            name = "linking/route-game-streams",
            before = "linking/find-defined-target",
            interests = {
                EventInterest {
                    Constraint { "event.type", "=", "select-target" },
                },
            },
            execute = function(event)
                local _, om, si, si_props, _, target = lutils:unwrap_select_target_event(event)

                if target or si_props["media.class"] ~= "Stream/Output/Audio" then
                    return
                end

                if not is_game_stream(si_props) then
                    return
                end

                local game_target = om:lookup {
                    type = "SiLinkable",
                    Constraint { "item.node.direction", "=", cutils.getTargetDirection(si_props) },
                    Constraint { "node.name", "=", "games" },
                }

                if game_target and lutils.canLink(si_props, game_target) then
                    log:info(si, "routing game stream to games")
                    event:set_data("target", game_target)
                end
            end
        }:register()
    '';

    wireplumberAudioBusPolicy = {
        "monitor.alsa.rules" = [
            {
                matches = [ { "node.name" = speaker; } ];
                actions.update-props = {
                    "session.suspend-timeout-seconds" = 0;
                };
            }
        ];
        "wireplumber.components" = [
            {
                name = "force-media-default.lua";
                type = "script/lua";
                provides = "custom.force-media-default";
            }
            {
                name = "route-game-streams.lua";
                type = "script/lua";
                provides = "custom.route-game-streams";
            }
        ];
        "wireplumber.profiles" = {
            main = {
                "custom.force-media-default" = "required";
                "custom.route-game-streams" = "required";
            };
        };
        "stream.rules" = [
            {
                matches = [
                    {
                        "media.type" = "Audio";
                        "media.category" = "Playback";
                        "media.role" = "Game";
                    }
                ];
                actions.update-props = {
                    "state.restore-target" = "false";
                };
            }
            {
                matches = [
                    {
                        "media.type" = "Audio";
                        "media.category" = "Playback";
                        "media.role" = "game";
                    }
                ];
                actions.update-props = {
                    "state.restore-target" = "false";
                };
            }
            {
                matches = [
                    {
                        "media.type" = "Audio";
                        "media.category" = "Playback";
                        "application.process.binary" = "ac-linux-manager";
                    }
                    {
                        "media.type" = "Audio";
                        "media.category" = "Playback";
                        "application.name" = "Steam";
                    }
                    {
                        "media.type" = "Audio";
                        "media.category" = "Playback";
                        "application.id" = "com.valvesoftware.Steam";
                    }
                    {
                        "media.type" = "Audio";
                        "media.category" = "Playback";
                        "application.process.binary" = "steam";
                    }
                    {
                        "media.type" = "Audio";
                        "media.category" = "Playback";
                        "application.process.binary" = "steamwebhelper";
                    }
                ];
                actions.update-props = {
                    "state.restore-target" = "false";
                };
            }
        ];
    };

    wireplumberAudioBusPolicyText = pkgsUnstable.lib.concatStringsSep "\n"
        (pkgsUnstable.lib.mapAttrsToList (section: content: "${section} = ${builtins.toJSON content}") wireplumberAudioBusPolicy);
in

{
    xdg.configFile."pipewire/pipewire.conf.d/93-audio-buses.conf".text = builtins.toJSON pipewireAudioBusConfig + "\n";
    xdg.configFile."wireplumber/wireplumber.conf.d/50-audio-bus-policy.conf".text = wireplumberAudioBusPolicyText;
    xdg.dataFile."wireplumber/scripts/force-media-default.lua".text = forceMediaDefaultScript;
    xdg.dataFile."wireplumber/scripts/route-game-streams.lua".text = routeGameStreamsScript;

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
