{ stableLib, pkgsUnstable, systemConfig, accentColor, inputs, ... }:

let
    plasmaAccentColor = stableLib.strings.concatMapStringsSep
        ","
        builtins.toString
        (with accentColor; [r g b]);
in

{
    programs.plasma = {
        enable = true;
        configFile = {
            kcminputrc.Keyboard.NumLock = 0;
            kdeglobals = {
                General = {
                    AccentColor = plasmaAccentColor;
                    XftHintStyle = "hintslight";
                    XftSubPixel = "none";
                    fixed = "${builtins.head systemConfig.fonts.fontconfig.defaultFonts.monospace},10,-1,5,50,0,0,0,0,0";
                    ColorScheme = "Sweet";
                };
                WM = {
                    # TODO: get from accentColor
                    activeBackground = "49,54,59";
                    activeBlend = "252,252,252";
                    activeForeground = "252,252,252";
                    inactiveBackground = "42,46,50";
                    inactiveBlend = "161,169,177";
                    inactiveForeground = "161,169,177";
                };
                KDE = {
                    widgetStyle = "kvantum-dark";
                };
            };
            kglobalshortcutsrc = {
                ksmserver._k_friendly_name = "Session Management";
                plasmashell._k_friendly_name = "Activity switching";
            };
            kscreenlockerrc = {
                Daemon.Autolock = false;
                Greeter.Theme = "Sweet";
            };
            ksmserverrc.General.confirmLogout = false;
            kwinrc = {
                Effect-blur = {
                    BlurStrength = 6;
                    NoiseStrength = 10;
                };
                Effect-windowview.BorderActivateAll = 9;
                MouseBindings = {
                    CommandAllKey = "Alt";
                    CommandAllWheel = "Change Opacity";
                    CommandTitlebarWheel = "Change Opacity";
                };
                Plugins = {
                    blurEnabled = true;
                    contrastEnabled = true;
                };
                TabBox = {
                    LayoutName = "thumbnails";
                    OrderMinimizedMode = 1;
                };
                Windows = {
                    DelayFocusInterval = 0;
                    ElectricBorderMaximize = false;
                    FocusPolicy = "FocusFollowsMouse";
                };
                "org.kde.kdecoration2" = {
                    ButtonsOnLeft = "F";
                    ButtonsOnRight = "IAX";
                    BorderSize = "None";
                    BorderSizeAuto = false;
                    library = "org.kde.kwin.aurorae";
                    theme = "__aurorae__svg__Sweet-Dark-transparent";
                };
            };
            ksplashrc.KSplash = {
                Engine = "KSplashQML";
                Theme = "Sweet";
            };
            plasmarc.Theme.name = "Sweet";
            kxkbrc.Layout = {
                Options = "caps:escape";
                ResetOldOptions = true;
            };
            plasma-localerc.Formats.LC_TIME = "C";
        };
    };

    # Theme files
    xdg.dataFile = {
        "plasma/look-and-feel/Sweet".source = "${pkgsUnstable.sweet-nova}/share/plasma/look-and-feel/com.github.eliverlara.sweet/";
        "plasma/desktoptheme/Sweet".source = inputs.sweet-kde;
        "aurorae/themes/Sweet-Dark-transparent".source = "${pkgsUnstable.sweet-nova}/share/aurorae/themes/Sweet-Dark-transparent";
        "color-schemes/Sweet.colors".source = "${pkgsUnstable.sweet-nova}/share/color-schemes/Sweet.colors";
    };
}
