args @ { stableLib, pkgsUnstable, systemConfig, accentColor, inputs, ... }:

let
    plasmaAccentColor = stableLib.strings.concatMapStringsSep
        ","
        builtins.toString
        (with accentColor; [r g b]);
    colorScheme = import ./colors.nix args;
    colorSchemeText = stableLib.generators.toINI {} colorScheme;
in

{
    home.packages = with pkgsUnstable; [
        pinentry-qt
        beauty-line-icon-theme
        kdePackages.qtmultimedia
    ];

    programs.plasma = {
        enable = true;

        workspace.iconTheme = "BeautyLine";
        workspace.colorScheme = "Main";

        configFile = {
            kcminputrc = {
                Keyboard.NumLock = 0;
                "Libinput/1/1/kanata".PointerAccelerationProfile = 1;
            };
            kdeglobals = colorScheme // {
                General = colorScheme.General // {
                    AccentColor = plasmaAccentColor;
                    XftHintStyle = "hintslight";
                    XftSubPixel = "none";
                    fixed = stableLib.mkIf (systemConfig != null)
                        "${builtins.head systemConfig.fonts.fontconfig.defaultFonts.monospace},10,-1,5,50,0,0,0,0,0";
                };
                KDE = colorScheme.KDE // {
                    widgetStyle = "kvantum-dark";
                };
            };
            kglobalshortcutsrc = {
                ksmserver._k_friendly_name = "Session Management";
                plasmashell._k_friendly_name = "Activity switching";
            };
            kscreenlockerrc = {
                Daemon = {
                    Autolock = false;
                    Timeout = 0;
                };
                Greeter.Theme = "Sweet";
            };
            ksmserverrc.General.confirmLogout = false;
            kwinrc = {
                Effect-blur = {
                    BlurStrength = 6;
                    NoiseStrength = 10;
                };
                Effect-windowview.BorderActivateAll = 9;
                Effect-overview.BorderActivate = 9;
                MouseBindings = {
                    CommandAllKey = "Alt";
                    CommandAll1 = "Activate, raise and move";
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
                    MultiScreenMode = 1; # only windows from current display
                };
                Windows = {
                    DelayFocusInterval = 0;
                    FocusPolicy = "FocusFollowsMouse";
                    FocusStealingPreventionLevel = 0;
                };
                "org.kde.kdecoration2" = {
                    ButtonsOnLeft = "F";
                    ButtonsOnRight = "IAX";
                    BorderSize = "None";
                    BorderSizeAuto = false;
                    library = "org.kde.kwin.aurorae";
                    theme = "__aurorae__svg__Sweet-Dark-transparent";
                };
                NightColor = {
                    Active = true;
                    NightTemperature = 5600;
                };
                Wayland.EnablePrimarySelection = false;
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
            plasmaparc.General = {
                AudioFeedback = false;
                VolumeStep = 1;
                VolumeOsd = false;
            };
        };

        powerdevil.AC = {
            dimDisplay.enable = false;
            turnOffDisplay.idleTimeout = "never";
            autoSuspend.action = "nothing";
            powerButtonAction = "sleep";
        };
    };

    # Theme files
    xdg.dataFile = {
        "plasma/look-and-feel/Sweet".source = "${pkgsUnstable.sweet-nova}/share/plasma/look-and-feel/com.github.eliverlara.sweet/";
        "plasma/desktoptheme/Sweet".source = inputs.sweet-kde;
        "aurorae/themes/Sweet-Dark-transparent".source = "${pkgsUnstable.sweet-nova}/share/aurorae/themes/Sweet-Dark-transparent";
        "color-schemes/Main.colors".source = pkgsUnstable.writeText "Main.colors" colorSchemeText;
    };
}
