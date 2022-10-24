{ pkgs, ... }:

{
    home.packages = with pkgs.gnomeExtensions; [ tailscale-status ];

    dconf.settings."org/gnome/shell".enabled-extensions = [ "tailscale-status@maxgallup.github.com" ];
}
