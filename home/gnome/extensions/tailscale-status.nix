{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnomeExtensions; [ tailscale-status ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "tailscale-status@maxgallup.github.com" ];
}
