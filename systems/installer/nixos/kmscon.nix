{ stableLib, ... }:

{
    services.getty.autologinUser = stableLib.mkForce "main";
}
