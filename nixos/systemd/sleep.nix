{ ... }:

{
    # Hibernation would violate this config's security model
    systemd.sleep.extraConfig = ''
        AllowHibernation=no
        AllowSuspendThenHibernate=no
        AllowHybridSleep=no
    '';
}
