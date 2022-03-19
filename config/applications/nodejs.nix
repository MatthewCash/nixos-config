{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [ nodejs-16_x ];
}