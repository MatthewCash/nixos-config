self: super:

{
    firefox-devedition-bin = super.firefox-devedition-bin.override (old: {
        icon = "firefox-developer-edition";
        desktopName = "Firefox Developer Edition";
        nameSuffix = "";
    });
}
