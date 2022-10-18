{ pkgs, ... }:

{
    home.packages = with pkgs.gnome; [ gnome-tweaks ];

    dconf.settings = {
        "org/gnome/tweaks" = {
            show-extensions-notice = false;
        };
    };
}
