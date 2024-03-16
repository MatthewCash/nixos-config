{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ celluloid ];
}
