{ pkgsUnstable, ... }:

{
    environment.systemPackages = with pkgsUnstable; [ python3Full ];
}