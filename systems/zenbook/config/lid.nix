{ ... }:

{
    services.logind = {
        lidSwitch = "lock";
        lidSwitchExternalPower = "lock";
    };
}
