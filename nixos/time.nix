{ persistPath, ... }:

{
    time.timeZone = "America/Los_Angeles";

    services.chrony.enable = true;

    environment.persistence.${persistPath}.directories = [{
        directory = "/var/lib/chrony";
        user = "chrony";
        group = "chrony";
        mode = "0750";
    }];
}
