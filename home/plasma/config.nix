args @ { stableLib, pkgsUnstable, systemConfig, accentColor, inputs, ... }:

let
    plasmaAccentColor = stableLib.strings.concatMapStringsSep
        ","
        builtins.toString
        (with accentColor; [r g b]);
    accentName = builtins.substring 1 6 accentColor.hex;
    colorScheme = import ./colors.nix args;
    colorSchemeText = stableLib.generators.toINI {
        mkSectionName = name: name;
    } colorScheme;

    sweetDesktopTheme = pkgsUnstable.runCommand "sweet-kde-${accentName}" {} ''
        cp -r ${inputs.sweet-kde} $out
        chmod -R u+w $out

        substituteInPlace $out/colors \
            --replace-fail "133,0,247" "${plasmaAccentColor}"

        sed -i \
            -e '/BackgroundNormal/s/=.*/=0,0,0/' \
            -e '/BackgroundAlternate/s/=.*/=0,0,0/' \
            -e '/activeBackground/s/=.*/=0,0,0/' \
            -e '/inactiveBackground/s/=.*/=0,0,0/' \
            $out/colors
        sed -i -e '/\[Colors:Selection\]/,/^\[/{s/BackgroundNormal=0,0,0/BackgroundNormal=${plasmaAccentColor}/}' $out/colors
        substituteInPlace $out/widgets/tabbar.svg \
            --replace-fail "#5800e2" "${accentColor.hex}" \
            --replace-fail "#ff00e6" "${accentColor.hex}" \
            --replace-fail "#a22f66" "${accentColor.hex}"

        for name in button lineedit listitem pager scrollbar tasks viewitem; do
            file=$out/widgets/$name.svgz
            gzip -cd "$file" \
                | sed 's/#bd93f9/${accentColor.hex}/g' \
                | gzip -c > "$file.tmp"
            mv "$file.tmp" "$file"
        done

    '';

    sweetLookAndFeel = pkgsUnstable.runCommand "sweet-look-and-feel-${accentName}" {} ''
        cp -r ${pkgsUnstable.sweet-nova}/share/plasma/look-and-feel/com.github.eliverlara.sweet $out
        chmod -R u+w $out

        substituteInPlace $out/contents/components/ActionButton.qml \
            --replace-fail "#c50ed2" "${accentColor.hex}"
        substituteInPlace $out/contents/logout/Logout.qml \
            --replace-fail "#c50ed2" "${accentColor.hex}"
        substituteInPlace $out/contents/lockscreen/MainBlock.qml \
            --replace-fail "#D300DC" "${accentColor.hex}" \
            --replace-fail "#8700FF" "${accentColor.hex}"
        substituteInPlace $out/contents/splash/images/busy.svg \
            --replace-fail "rgb(255,0,145)" "rgb(${plasmaAccentColor})"

        ${pkgsUnstable.imagemagick}/bin/magick \
            $out/contents/splash/images/background.png \
            -colorspace gray -fill '${accentColor.hex}' -tint 100 \
            $TMPDIR/background.png
        mv $TMPDIR/background.png $out/contents/splash/images/background.png
        ${pkgsUnstable.imagemagick}/bin/magick \
            $out/contents/splash/images/sweetlogo.png \
            -colorspace gray -fill '${accentColor.hex}' -tint 100 \
            $TMPDIR/sweetlogo.png
        mv $TMPDIR/sweetlogo.png $out/contents/splash/images/sweetlogo.png
    '';

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
        "plasma/look-and-feel/Sweet".source = sweetLookAndFeel;
        "plasma/desktoptheme/Sweet".source = sweetDesktopTheme;
        "aurorae/themes/Sweet-Dark-transparent".source = "${pkgsUnstable.sweet-nova}/share/aurorae/themes/Sweet-Dark-transparent";
        "color-schemes/Main.colors".source = pkgsUnstable.writeText "Main.colors" colorSchemeText;
    };
}
