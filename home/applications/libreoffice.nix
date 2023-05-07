{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ libreoffice-fresh ];
}
