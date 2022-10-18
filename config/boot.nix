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
}
