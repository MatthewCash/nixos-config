{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ gnome-console ];
}
