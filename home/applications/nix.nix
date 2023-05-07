{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ nix-prefetch ];
}
