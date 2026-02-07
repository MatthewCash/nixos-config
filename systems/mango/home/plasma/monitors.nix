{ ... }:

let
  monitorsConfig = [
    {
      name = "outputs";
      data = [
        {
          allowDdcCi = true;
          allowSdrSoftwareBrightness = true;
          autoRotation = "InTabletMode";
          brightness = 1;
          colorPowerTradeoff = "PreferEfficiency";
          colorProfileSource = "sRGB";
          connectorName = "DP-1";
          detectedDdcCi = false;
          edidHash = "66fef7a9ea93afb73309aa6d66fc0191";
          edidIdentifier = "GSM 30491 468977 9 2018 0";
          edrPolicy = "always";
          highDynamicRange = false;
          iccProfilePath = "";
          maxBitsPerColor = 0;
          mode = {
            width = 2560;
            height = 1440;
            refreshRate = 144000;
          };
          overscan = 0;
          rgbRange = "Automatic";
          scale = 1;
          sdrBrightness = 200;
          sdrGamutWideness = 0;
          transform = "Normal";
          uuid = "f048183e-d5e5-4465-978b-7b2b929b2bc0";
          vrrPolicy = "Never";
          wideColorGamut = false;
        }
        {
          allowDdcCi = true;
          allowSdrSoftwareBrightness = true;
          autoRotation = "InTabletMode";
          brightness = 1;
          colorPowerTradeoff = "PreferEfficiency";
          colorProfileSource = "sRGB";
          connectorName = "DP-2";
          detectedDdcCi = false;
          edidHash = "0aabf97c026109daf5d51c0001d31a09";
          edidIdentifier = "ACR 1863 68242030 41 2020 0";
          edrPolicy = "always";
          highDynamicRange = false;
          iccProfilePath = "";
          maxBitsPerColor = 0;
          mode = {
            width = 3840;
            height = 2160;
            refreshRate = 60000;
          };
          overscan = 0;
          rgbRange = "Automatic";
          scale = 1;
          sdrBrightness = 400;
          sdrGamutWideness = 0;
          transform = "Normal";
          uuid = "5476a73f-2e63-4490-b107-3080a6a324ea";
          vrrPolicy = "Never";
          wideColorGamut = false;
        }
      ];
    }

    {
      name = "setups";
      data = [
        {
          lidClosed = false;
          outputs = [
            {
              enabled = true;
              outputIndex = 0;
              position = {
                x = 0;
                y = 500;
              };
              priority = 0;
              replicationSource = "";
            }
            {
              enabled = true;
              outputIndex = 1;
              position = {
                x = 2560;
                y = 0;
              };
              priority = 1;
              replicationSource = "";
            }
          ];
        }
        {
          lidClosed = false;
          outputs = [
            {
              enabled = true;
              outputIndex = 0;
              position = {
                x = 0;
                y = 0;
              };
              priority = 0;
              replicationSource = "";
            }
          ];
        }
        {
          lidClosed = false;
          outputs = [
            {
              enabled = true;
              outputIndex = 1;
              position = {
                x = 0;
                y = 0;
              };
              priority = 0;
              replicationSource = "";
            }
          ];
        }
      ];
    }
  ];
in
{
    xdg.configFile."kwinoutputconfig.json".text = builtins.toJSON monitorsConfig;
}
