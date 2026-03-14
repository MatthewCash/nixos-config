{ ... }:

{
    # Hibernation would violate this config's security model
    systemd.sleep.settings.Sleep = {
        AllowHibernation = "no";
        AllowSuspendThenHibernate = "no";
        AllowHybridSleep = "no";
    };
}
