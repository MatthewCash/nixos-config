{ ... }:

{
    services.usbguard = {
        enable = true;
        dbus.enable = true;
        IPCAllowedGroups = [ "usbguard" "wheel" ];
        rules = ''
             allow with-interface one-of { 03:00:01 03:01:01 } if !allowed-matches(with-interface one-of { 03:00:01 03:01:01 })
        '';
    };
}
