{ ... }:

let
    round = value: builtins.floor (value + 0.5);
    rectToGeometry = rect: offset: {
        position = "${toString (round rect.x + offset.x)},${toString (round rect.y + offset.y)}";
        size = "${toString (round rect.width + offset.width)},${toString (round rect.height + offset.height)}";
    };

    screen = {
        x = 2560;
        y = 0;
        width = 3840;
        height = 2160;
        uuid = "5476a73f-2e63-4490-b107-3080a6a324ea";
    };

    leftScreen = {
        x = 0;
        y = 500;
        width = 2560;
        height = 1440;
    };

    centerOnScreen = screen: size: {
        position = "${toString (round (screen.x + (screen.width - size.width) / 2))},${toString (round (screen.y + (screen.height - size.height) / 2))}";
        size = "${toString size.width},${toString size.height}";
    };

    panel = {
        height = 45;
        # Floating panels need extra clearance beyond their configured height.
        spacerHeight = 60;
    };

    layout = rec {
        tilePadding = 9;
        leftWidth = 0.5;
        rightWidth = 1 - leftWidth;
        firefoxHeight = 0.65;
        panelSpacerHeight = 1.0 * panel.spacerHeight / screen.height;
        audioRowHeight = 1 - firefoxHeight - panelSpacerHeight;
        vesktopHeight = 0.5;

        leftWidthPixels = screen.width * leftWidth;
        audioRowVisualWidth = leftWidthPixels - tilePadding - (tilePadding - tileGap.innerStart);
        audioPrimaryVisualWidth = round ((audioRowVisualWidth - (2 * tilePadding)) / 3.0);
        guitarixTileWidthPixels = audioPrimaryVisualWidth - (tileGap.innerEnd - tileGap.outerStart);
        pipewireBusMixerTileWidthPixels = audioPrimaryVisualWidth - (tileGap.innerEnd - tileGap.innerStart);
        audioControlsTileWidthPixels = leftWidthPixels - guitarixTileWidthPixels - pipewireBusMixerTileWidthPixels;

        guitarixTileWidth = 1.0 * guitarixTileWidthPixels / screen.width;
        pipewireBusMixerTileWidth = 1.0 * pipewireBusMixerTileWidthPixels / screen.width;
        audioControlsWidth = 1.0 * audioControlsTileWidthPixels / screen.width;
    };

    tileGap = rec {
        outerStart = layout.tilePadding;
        innerStart = round (layout.tilePadding / 2.0);
        innerEnd = 0 - (layout.tilePadding - innerStart);
        outerEnd = 1 - layout.tilePadding;
    };

    edgeStart = edge: if edge == "outer" then tileGap.outerStart else tileGap.innerStart;
    edgeEnd = edge: if edge == "outer" then tileGap.outerEnd else tileGap.innerEnd;

    tileToGeometry = tile: edges:
        let
            left = edgeStart edges.left;
            top = edgeStart edges.top;
            right = edgeEnd edges.right;
            bottom = edgeEnd edges.bottom;
        in rectToGeometry tile {
            x = left;
            y = top;
            width = right - left;
            height = bottom - top;
        };

    tiles = rec {
        firefox = {
            x = screen.x;
            y = screen.y;
            width = screen.width * layout.leftWidth;
            height = screen.height * layout.firefoxHeight;
        };
        guitarix = {
            x = screen.x;
            y = screen.y + firefox.height;
            width = layout.guitarixTileWidthPixels;
            height = screen.height * layout.audioRowHeight;
        };
        pipewireBusMixer = {
            x = guitarix.x + guitarix.width;
            y = guitarix.y;
            width = layout.pipewireBusMixerTileWidthPixels;
            height = guitarix.height;
        };
        vesktopPersonal = {
            x = screen.x + screen.width * layout.leftWidth;
            y = screen.y;
            width = screen.width * layout.rightWidth;
            height = screen.height * layout.vesktopHeight;
        };
        vesktopBusiness = {
            x = vesktopPersonal.x;
            y = screen.y + vesktopPersonal.height;
            width = vesktopPersonal.width;
            height = vesktopPersonal.height;
        };
    };

    ruleGeometry = {
        firefox = tileToGeometry tiles.firefox { left = "outer"; top = "outer"; right = "inner"; bottom = "inner"; };
        guitarix = tileToGeometry tiles.guitarix { left = "outer"; top = "inner"; right = "inner"; bottom = "inner"; };
        pipewireBusMixer = tileToGeometry tiles.pipewireBusMixer { left = "inner"; top = "inner"; right = "inner"; bottom = "inner"; };
        vesktopPersonal = tileToGeometry tiles.vesktopPersonal { left = "inner"; top = "outer"; right = "outer"; bottom = "inner"; };
        vesktopBusiness = tileToGeometry tiles.vesktopBusiness { left = "inner"; top = "inner"; right = "outer"; bottom = "outer"; };
        centeredLeft = centerOnScreen leftScreen { width = 1280; height = 800; };
    };
in

{
    programs.plasma.kwin = {
        virtualDesktops = let
            names = [ "main" ];
        in {
            inherit names;
            number = builtins.length names;
        };
        tiling = {
            padding = layout.tilePadding;
            layout = {
                id = "Desktop_1/${screen.uuid}";
                tiles = {
                    layoutDirection = "horizontal";
                    tiles = [
                        {
                            layoutDirection = "vertical";
                            width = layout.leftWidth;
                            tiles = [
                                { height = layout.firefoxHeight; }
                                {
                                    layoutDirection = "horizontal";
                                    height = layout.audioRowHeight;
                                    tiles = [
                                        { width = layout.guitarixTileWidth; }
                                        { width = layout.pipewireBusMixerTileWidth; }
                                        { width = layout.audioControlsWidth; }
                                    ];
                                }
                                { height = layout.panelSpacerHeight; }
                            ];
                        }
                        {
                            layoutDirection = "vertical";
                            width = layout.rightWidth;
                            tiles = [
                                { height = layout.vesktopHeight; }
                                { height = layout.vesktopHeight; }
                            ];
                        }
                    ];
                };
            };
        };
    };

    programs.plasma.configFile.kwinrc."Tiling/Desktop_1/${screen.uuid}".padding = layout.tilePadding;

    programs.plasma.window-rules = [
        {
            description = "Position Thunderbird";
            match.window-class = {
                value = "thunderbird";
                match-whole = false;
            };
            apply = {
                position = "0,500";
                maximizehoriz = true;
                maximizevert = true;
            };
        }
        {
            description = "Position Firefox Layout";
            match.window-class = {
                value = "org.mozilla.Firefox.layout";
                match-whole = false;
            };
            apply = {
                position = "0,500";
                maximizehoriz = true;
                maximizevert = true;
            };
        }
        {
            description = "Position Dolphin";
            match.window-class = {
                value = "org.kde.dolphin";
                match-whole = false;
            };
            apply = {
                inherit (ruleGeometry.centeredLeft) position size;
            };
        }
        {
            description = "Position Konsole";
            match.window-class = {
                value = "org.kde.konsole";
                match-whole = false;
            };
            apply = {
                inherit (ruleGeometry.centeredLeft) position size;
            };
        }
        {
            description = "Position Firefox Floating";
            match.window-class = {
                value = "org.mozilla.Firefox.floating";
                match-whole = false;
            };
            apply.position = "500,600";
        }
        {
            description = "Position Prism Launcher";
            match.window-class = {
                value = "org.prismlauncher.PrismLauncher";
                match-whole = false;
            };
            apply.position = "500,600";
        }
        {
            description = "Position Guitarix";
            match.window-class = {
                value = "guitarix";
                match-whole = false;
            };
            apply = {
                position.value = ruleGeometry.guitarix.position;
                size.value = ruleGeometry.guitarix.size;
                noborder = true;
            };
        }
        {
            description = "Position Channel Mixer";
            match = {
                window-class = {
                    value = "channel-mixer";
                    match-whole = false;
                };
                title = "Channel Mixer";
            };
            apply = {
                position.value = ruleGeometry.pipewireBusMixer.position;
                size.value = ruleGeometry.pipewireBusMixer.size;
            };
        }
        {
            description = "Hide titlebar for Minecraft";
            match.window-class = {
                value = "Minecraft";
                type = "substring";
                match-whole = false;
            };
            apply = {
                maximizehoriz = true;
                maximizevert = true;
                noborder = true;
            };
        }
        {
            description = "Hide titlebar for Minecraft (AxolotlClient)";
            match.window-class = {
                value = "AxolotlClient";
                type = "substring";
                match-whole = false;
            };
            apply = {
                maximizehoriz = true;
                maximizevert = true;
                noborder = true;
            };
        }

        {
            description = "Position Firefox Transparent";
            match.window-class = {
                value = "org.mozilla.Firefox.transparent";
                match-whole = false;
            };
            apply = {
                inherit (ruleGeometry.firefox) position size;
                ignoregeometry = {
                    value = true;
                    apply = "force";
                };
            };
        }
        {
            description = "Position Vesktop Personal";
            match.window-class = {
                value = "com.discord.vesktop.personal";
                match-whole = false;
            };
            apply = {
                inherit (ruleGeometry.vesktopPersonal) position size;
                ignoregeometry = true;
            };
        }
        {
            description = "Position Vesktop Business";
            match.window-class = {
                value = "com.discord.vesktop.business";
                match-whole = false;
            };
            apply = {
                inherit (ruleGeometry.vesktopBusiness) position size;
                ignoregeometry = true;
            };
        }
    ];
}
