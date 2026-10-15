{ pkgsUnstable, ... }:

{
    hardware.graphics = {
        extraPackages = with pkgsUnstable; [ intel-media-driver ];
    };
}
