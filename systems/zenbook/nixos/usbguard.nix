{ ... }:

{
    services.usbguard.rules = ''
        allow id 13d3:56eb serial "0x0001" name "USB2.0 HD UVC WebCam" hash "ezm5LYL3LhRbJSGPhD/Ei/IoLAHoN2ki0jg60UyzKso=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 0e:01:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:02:00 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 fe:01:01 } with-connect-type "hardwired"
        allow id 8087:0026 serial "" name "" hash "Z5csNGxiUukPPZwSHPyUqpVCNagsfOSSNL2CfXhw4IY=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "3-10" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "not used"
    '';
}
