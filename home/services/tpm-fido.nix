{ pkgsUnstable, stableLib, config, ... }:

{
    systemd.user.services.tpm-fido = {
        Unit = {
            Description = "tpm-fido service";
            After = [ "graphical-session-pre.target" ];
            PartOf = [ "graphical-session.target" ];
        };
        Service = {
            ExecStart = stableLib.getExe pkgsUnstable.tpm-fido;
            Environment = "PATH=${config.home.profileDirectory}/bin"; # to find profile's pinentry
            Restart = "always";
        };
        Install.WantedBy = [ "graphical-session.target" ];
    };
}
