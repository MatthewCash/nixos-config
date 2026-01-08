{ persistPath, stableLib, ... }:

{
    environment.persistence.${persistPath}.directories = [ "/etc/secureboot" ];

    boot = {
        loader.systemd-boot.enable = stableLib.mkForce false;

        lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
            autoGenerateKeys.enable = true; # this doesn't actually work yet
        };
    };
}
