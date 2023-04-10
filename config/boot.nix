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

    boot.initrd.systemd.enable = true;

    systemd.services."prepare-kexec".wantedBy = [ "multi-user.target" ];
}
