{ pkgsStable, pkgsUnstable, stableLib, config, ... }:

{
    systemd.user.services = {
        tpm-fido = {
            Unit.Description = "tmp-fido service";
            Service = {
                ExecStart = stableLib.getExe pkgsUnstable.tpm-fido;
                Environment = "PATH=${config.home.profileDirectory}/bin"; # to find profile's pinentry
                Restart = "always";
            };
            Install.WantedBy = [ "default.target" ];
        };

        # Service creates a predictable name to pass to sandboxed apps
        tpm-fido-node = {
            Unit = {
                Description = "Create link to tpm-fido hidraw node in XDG_RUNTIME_DIR";
                After = [ "tpm-fido.service" ];
                Requires = [ "tpm-fido.service" ];
            };

            Service = {
                Type = "oneshot";
                ExecStart = pkgsStable.writeShellScript "tpm-fido-node" /* bash */ ''
                    link_path="$XDG_RUNTIME_DIR/tpm-fido-hidrawnode"

                    hidraw_node="$(${stableLib.getExe' pkgsStable.coreutils "basename"} $(ls /sys/bus/hid/devices/0003:15D9:0A37.????/hidraw/ | ${stableLib.getExe pkgsStable.gnused} -n 1p))"

                    ${stableLib.getExe' pkgsStable.coreutils "rm"} -f $link_path
                    ${stableLib.getExe' pkgsStable.coreutils "ln"} -sf "/dev/$hidraw_node" $link_path
                '';
            };
            Install.WantedBy = [ "default.target" ];
        };
    };
}
