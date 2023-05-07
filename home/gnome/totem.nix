{ pkgsUnstable, ... }:

{
    dconf.settings."org/gnome/Totem".subtitle-font = "Sans 12";

    home.packages = with pkgsUnstable.gnome; [ totem ];
}
