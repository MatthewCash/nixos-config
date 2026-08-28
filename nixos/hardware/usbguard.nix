{ ... }:

{
    services.usbguard = {
        enable = true;
        dbus.enable = true;
        IPCAllowedGroups = [ "usbguard" "wheel" ];
    };
}
