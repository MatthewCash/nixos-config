{ pkgs, inputs, system, ... }:

{
    fonts.fonts = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
        ipafont
        inputs.aurebesh-fonts.defaultPackage.${system}
    ];
}
