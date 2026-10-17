{ ... }:

{
    # Limit "A stop job is running..." delay
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

    systemd.user.settings.Manager.DefaultTimeoutStopSec = "10s";

    services.journald.settings.Journal = {
        SystemMaxUse = "5G";
        MaxRetentionSec = "30day";
    };

    systemd.coredump.settings.Coredump = {
        Storage = "external";
        Compress = "yes";
        MaxUse = "5G";
        KeepFree = "4G";
        ExternalSizeMax = "2G";
    };
}
