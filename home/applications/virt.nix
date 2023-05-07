{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ virt-manager ];
}
