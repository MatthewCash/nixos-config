{ pkgsUnstable, ... }:

{
    environment.systemPackages = with pkgsUnstable; [ nodejs-16_x ];
}