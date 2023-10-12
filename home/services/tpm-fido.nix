{ pkgsStable, pkgsUnstable, ... }:

{
    services.tpm-fido = {
        enable = true;
        extraPackages = with pkgsUnstable; [ pinentry-gnome ];
    };

    systemd.user.services.tpm-fido-node = {
        Unit.Description = "Create link to tpm-fido hidraw node in XDG_RUNTIME_DIR";

        Service = {
            Type = "oneshot";
            ExecStart = pkgsStable.writeShellScript "tpm-fido-node" /* bash */ ''
                hidraw_node="$(${pkgsStable.coreutils}/bin/basename $(ls /sys/bus/hid/devices/0003:15D9:0A37.0003/hidraw/ | ${pkgsStable.gnused}/bin/sed -n 1p))"
                ${pkgsStable.coreutils}/bin/ln -s "/dev/$hidraw_node" $XDG_RUNTIME_DIR/tpm-fido-hidrawnode
            '';
        };
        Install.WantedBy = [ "default.target" ];
    };
}
