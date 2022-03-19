{ pkgs, ... }:

{
    hardware.opengl = {
        extraPackages = with pkgs; [
            glxinfo
            
            intel-media-driver
            vaapiIntel
        ];
    };
}