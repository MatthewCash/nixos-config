{ persistPath, stableLib, ... }:

{
    environment.persistence.${persistPath}.directories = [ "/etc/secureboot" ];

    boot = {
        bootspec.enable = true;

        loader.systemd-boot.enable = stableLib.mkForce false;

        lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
        };
    };
}
