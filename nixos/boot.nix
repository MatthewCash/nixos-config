{ ... }:

{
    boot.loader = {
        efi.canTouchEfiVariables = true;

        systemd-boot = {
            enable = true;
            consoleMode = "max";
            editor = false;
            configurationLimit = 20;
        };
    };

    systemd.services."prepare-kexec".wantedBy = [ "multi-user.target" ];

    environment.sessionVariables.SYSTEMCTL_SKIP_AUTO_KEXEC = "1";
}
