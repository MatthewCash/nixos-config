{ ... }:

{
    services.usbguard.rules = ''
        # Built-in webcam
        allow id 13d3:56eb serial "0x0001" name "USB2.0 HD UVC WebCam" hash "ezm5LYL3LhRbJSGPhD/Ei/IoLAHoN2ki0jg60UyzKso=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 fe:01:01 } with-connect-type "hardwired"

        # Built-in Intel AX201 Bluetooth
        allow id 8087:0026 serial "" name "" hash "Z5csNGxiUukPPZwSHPyUqpVCNagsfOSSNL2CfXhw4IY=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-10" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"

        # External USB hub — two chips (USB 3.0 + USB 2.0) for the same physical hub
        allow id 05e3:0626 serial "" name "USB3.1 Hub" hash "15SBGsOo8K+JjtOKSCn7t0i6ifer4wmhzep1yEB5pLQ=" parent-hash "4Q3Ski/Lqi8RbTFr10zFlIpagY9AKVMszyzBQJVKE+c=" via-port "2-1" with-interface 09:00:00 with-connect-type "hotplug"
        allow id 05e3:0610 serial "" name "USB2.1 Hub" hash "CbRB9LX/JdGjNWCYSOcIwMVXE0UpOR03LCotWrTbuCM=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-3" with-interface 09:00:00 with-connect-type "hotplug"

        # Logitech Unifying Receiver — handles both paired keyboard and mouse
        allow id 046d:c52b serial "" name "USB Receiver" hash "djeL7wNsJBQMuBiqUyWflgupndhsbPkbOih8g3L6OeA=" parent-hash "CbRB9LX/JdGjNWCYSOcIwMVXE0UpOR03LCotWrTbuCM=" via-port "3-3.4" with-interface { 03:01:01 03:01:02 03:00:00 } with-connect-type "unknown"

        # Realtek RTL8153 Gigabit Ethernet adapter
        allow id 0bda:8153 serial "001004DC8" name "USB 10/100/1000 LAN" hash "b3vglT1/pN2WmDq3RW3eeG9VyfXnsH8QXW9Uh+ne2iY=" parent-hash "15SBGsOo8K+JjtOKSCn7t0i6ifer4wmhzep1yEB5pLQ=" with-interface { ff:ff:00 02:06:00 0a:00:00 0a:00:00 } with-connect-type "unknown"
    '';
}
