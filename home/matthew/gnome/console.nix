{ pkgs, ... }:

{
    home.packages = with pkgs; [ gnome-console ];
}
