{ pkgsUnstable, ... }:

{
    hardware.amdgpu = {
        initrd.enable = true;
        overdrive.enable = true;
    };

    services.lact = {
        enable = true;
        settings = {
            version = 6;

            daemon = {
                log_level = "info";
                admin_group = "wheel";
            };

            # this gpu crashes under heavy load :/
            gpus."1002:744C-1849:5304-0000:03:00.0".max_core_clock = 1700;
        };
    };

    systemd.services.lactd = {
        environment.LACT_DAEMON_CONFIG_DIR = "/run/lactd-config";

        serviceConfig = {
            RuntimeDirectory = "lactd-config";
            ExecStartPre = [
                "${pkgsUnstable.coreutils}/bin/install -m 0600 /etc/lact/config.yaml /run/lactd-config/config.yaml"
                "-${pkgsUnstable.coreutils}/bin/rm -f /run/lactd.sock"
            ];
            ExecStopPost = "-${pkgsUnstable.coreutils}/bin/rm -f /run/lactd.sock";
        };
    };
}
