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

    kwinScriptId = "prismlaunchermute";
    kwinScriptBusName = "dev.matthew.PrismLauncherMute";
    kwinScriptPath = "/dev/matthew/PrismLauncherMute";
    mutePythonEnv = pkgsUnstable.python313.withPackages (ps: with ps; [ dbus-fast psutil pulsectl-asyncio ]);

    kwinMuteScript = pkgsUnstable.writeText "prismlaunchermute-main.js" /* javascript */ ''
        function notifyActiveWindow(window) {
            const pid = window && window.pid ? window.pid : 0;
            callDBus(
                "${kwinScriptBusName}",
                "${kwinScriptPath}",
                "${kwinScriptBusName}",
                "SetActivePid",
                pid
            );
        }

        workspace.windowActivated.connect(notifyActiveWindow);
        notifyActiveWindow(workspace.activeWindow);
    '';

    kwinMuteMetadata = pkgsUnstable.writeText "prismlaunchermute-metadata.json" (builtins.toJSON {
        KPlugin = {
            Name = "PrismLauncher Mute";
            Description = "Notify a helper service when the active window changes";
            Id = kwinScriptId;
            Version = "1.0";
            License = "MIT";
        };
        "X-Plasma-API" = "javascript";
        "X-Plasma-MainScript" = "code/main.js";
        KPackageStructure = "KWin/Script";
    });

    muteMinecraftWhenUnfocused = pkgsUnstable.writeTextFile {
        name = "mute-minecraft-when-unfocused";
        destination = "/bin/mute-minecraft-when-unfocused";
        executable = true;
        text = /* python */ ''
        #!${mutePythonEnv}/bin/python3
        import asyncio, subprocess, psutil
        from dbus_fast.aio import MessageBus
        from dbus_fast.annotations import DBusInt32
        from dbus_fast.service import ServiceInterface, dbus_method
        from pulsectl_asyncio import PulseAsync

        kdotool = "${pkgsUnstable.kdotool}/bin/kdotool"
        BUS_NAME = "${kwinScriptBusName}"
        OBJECT_PATH = "${kwinScriptPath}"

        async def _active_pid():
            proc = await asyncio.create_subprocess_exec(
                kdotool, "getactivewindow", "getwindowpid",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.DEVNULL
            )
            out, _ = await proc.communicate()
            try:
                return int(out.decode().strip())
            except (ValueError, TypeError):
                return None

        def _prism_child(pid):
            try:
                p = psutil.Process(pid)
                while p:
                    if "prismlauncher" in p.name().lower():
                        return True
                    p = p.parent()
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
            return False

        class PrismLauncherMute(ServiceInterface):
            def __init__(self, pulse):
                super().__init__(BUS_NAME)
                self.pulse = pulse
                self.last_pid = object()

            async def _sync_mute(self, pid):
                if pid == self.last_pid:
                    return
                self.last_pid = pid
                muted = not (pid and _prism_child(pid))
                await self._set_matching_inputs(muted)

            async def _set_matching_inputs(self, muted):
                sink_inputs = await self.pulse.sink_input_list()
                seen = set()
                for si in sink_inputs:
                    if si.index in seen:
                        continue
                    seen.add(si.index)
                    props = si.proplist
                    name = (props.get("node.name", "") or "").lower()
                    binary = (props.get("application.process.binary", "") or "").lower()
                    role = (props.get("media.role", "") or "").lower()
                    if ("java" in name or "java" in binary) and "game" in role:
                        await self.pulse.sink_input_mute(si.index, mute=muted)

            @dbus_method()
            async def SetActivePid(self, pid: DBusInt32):
                await self._sync_mute(pid if pid > 0 else None)

        async def main():
            async with PulseAsync("mute-minecraft") as pulse:
                bus = await MessageBus().connect()
                interface = PrismLauncherMute(pulse)
                bus.export(OBJECT_PATH, interface)
                await bus.request_name(BUS_NAME)

                # Seed the initial state in case the KWin script sent its first
                # activation event before this service owned the bus name.
                await interface._sync_mute(await _active_pid())

                await bus.wait_for_disconnect()

        asyncio.run(main())
        '';
    };
in

{
    home.persistence."${persistenceHomePath}".directories = [
        ".local/share/PrismLauncher"
    ];

    home.packages = [ wrappedPrismlauncher.config.env ];

    programs.plasma.configFile.kwinrc.Plugins."${kwinScriptId}Enabled" = true;

    xdg.dataFile = {
        "kwin/scripts/${kwinScriptId}/contents/code/main.js".source = kwinMuteScript;
        "kwin/scripts/${kwinScriptId}/metadata.json".source = kwinMuteMetadata;
    };

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
            ExecStartPost = "${pkgsUnstable.qt6.qttools}/bin/qdbus org.kde.KWin /KWin reconfigure";
            Restart = "always";
            RestartSec = 1;
        };

        Install.WantedBy = [ "graphical-session.target" ];
    };
}
