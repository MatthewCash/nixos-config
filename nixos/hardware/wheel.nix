{ pkgsUnstable, ... }:

{
    # This is for a Logitech G920
    services.udev = {
        packages = with pkgsUnstable; [ oversteer ];
        extraRules = ''
            ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c261", RUN+="${pkgsUnstable.usb-modeswitch}/bin/usb_modeswitch -v 046d -p c261 -m 01 -r 01 -C 03 -M '0f00010142'"
        '';
    };
}
