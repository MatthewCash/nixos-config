{ pkgsStable, inputs, system, ... }:

{
    fonts.fonts = with pkgsStable; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
        ipafont
        inputs.aurebesh-fonts.defaultPackage.${system}
    ];
}
