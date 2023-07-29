{ pkgsStable, inputs, system, ... }:

{
    fonts.packages = with pkgsStable; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
        ipafont
        inputs.aurebesh-fonts.defaultPackage.${system}
    ];
}
