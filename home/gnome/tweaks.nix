{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ gnome-tweaks ];

    dconf.settings = {
        "org/gnome/tweaks" = {
            show-extensions-notice = false;
        };
    };
}
