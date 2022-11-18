{ pkgsUnstable, ... }:

{
    hardware.opengl = {
        extraPackages = with pkgsUnstable; [ intel-media-driver ];
    };
}
