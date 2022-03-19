{ pkgs, ... }:

{
    fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
        ipafont
    ];
}
