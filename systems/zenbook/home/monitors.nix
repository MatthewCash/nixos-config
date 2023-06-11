{ customLib, ... }:

let
    internal = {
        scale = 1;
        primary = "yes";
        monitor = {
            monitorspec = {
                connector = "eDP-1";
                vendor = "AUO";
                product = "0x323d";
                serial = "0x00000000";
            };
            mode = {
                width = 1920;
                height = 1080;
                rate = "60.049468994140625";
            };
        };
    };

    screenpad = {
        scale = 1;
        transform = {
            rotation = "right";
            flipped = "no";
        };
        monitor = {
            monitorspec = {
                connector = "HDMI-2";
                vendor = "TSB";
                product = "ScreenXpert-";
                serial = "0x88888800";
            };
            mode = {
                width = 1080;
                height = 2160;
                rate = "50.034282684326172";
            };
        };
    };

    projector = {
        scale = 1;
        monitor = {
            monitorspec = {
                connector = "HDMI-1";
                vendor = "MST";
                product = "MStar Demo";
                serial = "0x00000001";
            };
            mode = {
                width = 1920;
                height = 1080;
                rate = "60.000";
            };
        };
    };

    configuration = [
        # No external monitors connected
        {
            logicalmonitor = [
                (internal // { x = 0; y = 0; })
            ];
        }
        {
            logicalmonitor = [
                (internal // { x = 120; y = 0; })
                (screenpad // { x = 0; y = 1080; })
            ];
        }
        # Projector connected
        {
            logicalmonitor = [
                (internal // { x = 0; y = 0; })
                (projector // { x = 1920; y = 0; })
            ];
        }
        {
            logicalmonitor = [
                (internal // { x = 120; y = 0; })
                (screenpad // { x = 0; y = 1080; })
                (projector // { x = 120 + 1920; y = 0; })
            ];
        }
    ];

    monitorsXml = customLib.toXML {
        monitors = {
            _version = 2;
            inherit configuration;
        };
    };

in

{
    xdg.configFile."monitors.xml".text = monitorsXml;
}