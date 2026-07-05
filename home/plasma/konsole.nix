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

        "Notification Messages" = {
            CloseAllEmptyTabs = true;
            CloseAllTabs = true;
            CloseSingleTab = true;
        };
    };

    programs.plasma.dataFile."konsole/Main.profile" = {
        Appearance = {
            ColorScheme = "Main";
            UseFontLineCharacters = false;
        };

        "Cursor Options".CursorShape = 1;

        General = {
            Name = "Main";
            Parent = "FALLBACK/";
        };

        "Interaction Options" = {
            CopyTextAsHTML = false;
            TrimLeadingSpacesInSelectedText = true;
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
                _hidden = true;
                _name = "mainToolBar";
                _noMerge = 1;
                text = "Main Toolbar";
                index = 0;
            };
        };
    };

    xdg.dataFile."kxmlgui5/konsole/sessionui.rc".text = customLib.toXML {
        gui = {
            _name = "session";
            _version = 36;
            _translationDomain = "kxmlgui5";
            MenuBar = {
                _alreadyVisited = 1;
            };
            ToolBar = {
                _alreadyVisited = 1;
                _hidden = true;
                _name = "sessionToolbar";
                _noMerge = 1;
                text = "Session Toolbar";
                index = 1;
            };
        };
    };
}
