{ ... }:

{
    services.logind = {
        lidSwitch = "lock";
        lidSwitchExternalPower = "lock";
        lidSwitchDocked = "ignore";
    };
}
