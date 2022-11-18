{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ helvum ];
}
