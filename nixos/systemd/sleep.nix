{ ... }:

{
    # Hibernation would violate this config's security model
    systemd.sleep.settings.Sleep = {
        AllowHibernation = "no";
        AllowSuspendThenHibernate = "no";
        AllowHybridSleep = "no";
    };

    # Keep low-battery warnings without taking an automatic power action.
    services.upower = {
        allowRiskyCriticalPowerAction = true;
        criticalPowerAction = "Ignore";
    };
}
