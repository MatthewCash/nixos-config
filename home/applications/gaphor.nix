{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ gaphor ];
}
