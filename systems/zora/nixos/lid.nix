{ ... }:

{
    services.logind.settings.Login = {
        HandleLidSwitch = "lock";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "ignore";
    };
}
