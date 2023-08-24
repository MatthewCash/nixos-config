{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ evince ];

    dconf.settings."org/gnome/evince/default" = {
        inverted-colors = true;
    };
}
