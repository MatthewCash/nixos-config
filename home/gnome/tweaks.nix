{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnome; [ gnome-tweaks ];

    dconf.settings = {
        "org/gnome/tweaks" = {
            show-extensions-notice = false;
        };
    };
}
