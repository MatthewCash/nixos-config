{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ libreoffice-stable];
}
