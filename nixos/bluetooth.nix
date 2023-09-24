{ persistPath, ... }:

{
    environment.persistence.${persistPath}.directories = [ "/var/lib/bluetooth" ];

    hardware.bluetooth.enable = true;
}
