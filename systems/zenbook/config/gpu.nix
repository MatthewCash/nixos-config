{ pkgs, ... }:

{
    hardware.opengl = {
        extraPackages = with pkgs; [ intel-media-driver ];
    };
}
