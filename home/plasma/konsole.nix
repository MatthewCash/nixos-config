{ customLib, stableLib, pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.kdePackages; [ konsole ];

    programs.plasma.configFile."konsolerc" = {
        General.ConfigVersion = 1;

        "Desktop Entry".DefaultProfile = "Main.profile";

        KonsoleWindow = {
            FocusFollowsMouse = true;
            RememberWindowSize = false;
        };

        TabBar = {
            CloseTabOnMiddleMouseButton = true;
            ExpandTabWidth = true;
        };

        MainWindow = {
            RestorePositionForNextInstance = false;
            ToolBarsMovable = "Disabled";
        };

        "Notification Messages".CloseAllEmptyTabs = true;
    };

    programs.plasma.dataFile."konsole/Main.profile" = {
        Appearance = {
            ColorScheme = "Main";
            UseFontLineChararacters = false;
        };

        "Cursor Options".CursorShape = 1;

        General = {
            Name = "Main";
            Parent = "FALLBACK/";
        };

        "Interaction Options" = {
            CopyTextAsHTML = false;
            TrimLeadingSpacesInSelectedTextt = true;
            TrimTrailingSpacesInSelectedText = true;
            UnderlineFilesEnabled = true;
        };
    };

    programs.plasma.dataFile."konsole/Main.colorscheme" =
    let
        setColor = names: color: builtins.listToAttrs (builtins.map (name : {
            inherit name; value.Color = color;
        }) names);
    in {
        General = {
            Anchor = "0.5,0.5";
            Blur = true;
            ColorRandomization = false;
            FillStyle = "Tile";
            Opacity = 0;
            Wallpaper = "";
            WallpaperFlipType = "NoFlip";
            WallpaperOpacity = 1;
        };
    } //
    setColor [ "Background" "BackgroundFaint" "BackgroundIntense" ] "0,0,0" //
    setColor [ "Foreground" "ForegroundFaint" "ForegroundIntense" ] "255,255,255";
    

    xdg.dataFile."kxmlgui5/konsole/konsoleui.rc".text = let
        shortcuts = {
            next-tab = "Ctrl+Tab; Ctrl+PgDown";
            previous-tab = "Ctrl+Shift+Tab; Ctrl+PgUp";
            last-used-tab = "";
            last-used-tab-reverse = "";
        };
    in customLib.toXML {
        gui = {
            _name = "konsole";
            _version = 20;
            _translationDomain = "kxmlgui5";
            ActionProperties.Action = [
                (stableLib.mapAttrsToList (name: value: {
                    _name = name;
                    _shortcut = value;
                }) shortcuts)
            ];
            MenuBar = {
                _alreadyVisited = 1;
                Menu._name = "plugins";
            };
            ToolBar = {
                _alreadyVisited = 1;
                _noMerge = 1;
                _name = "mainToolBar";
                text = "Main Toolbar";
                index = 0;
                Action = builtins.map (x: { _name = x; }) [
                    "split-view"
                    "new-tab"
                    "new-window"
                ];
            };
        };
    };
}
