{ persistPath, ... }:

{
    environment.persistence.${persistPath}.directories = [ "/var/lib/waydroid" ];

    virtualisation.waydroid.enable = true;
}
