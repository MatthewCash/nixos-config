{ customLib, ... }:

let
    configuration = [
        # No external displays
        {
            logicalmonitor = [
                # Screenpad
                {
                    x = 1920;
                    y = 162;
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
                }

                # Main Screen
                {
                    x = 0;
                    y = 0;
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
                }
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