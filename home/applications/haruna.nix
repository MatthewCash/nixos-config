{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ haruna ];
}
