{ pkgsStable, pkgsUnstable, stableLib, ... }:

{
    services.tpm-fido = {
        enable = true;
        extraPackages = with pkgsUnstable; [ pinentry-gnome3 ];
    };

    systemd.user.services.tpm-fido-node = {
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
}
