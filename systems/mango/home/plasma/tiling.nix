{ ... }:

{
    programs.plasma.kwin = {
        virtualDesktops = let
            names = [ "main" ];
        in {
            inherit names;
            number = builtins.length names;
        };
        tiling = {
            padding = 9;
            layout = {
                id = "Desktop_1/5476a73f-2e63-4490-b107-3080a6a324ea";
                tiles = {
                    layoutDirection = "horizontal";
                    tiles = [
                        {
                            layoutDirection = "vertical";
                            width = 0.5;
                            tiles = [
                                { height = 0.65; } # firefox
                                { height = 0.322; } # audio controls
                                { height = 0.028; } # panel spacer
                            ];
                        }
                        {
                            layoutDirection = "vertical";
                            width = 0.5;
                            tiles = [
                                { height = 0.5; } # webcord 1
                                { height = 0.5; } # webcord 2
                            ];
                        }
                    ];
                };
            };
        };
    };
}
