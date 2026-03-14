{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ crosspipe ];
}
