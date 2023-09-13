{ pkgsStable, inputs, system, ... }:

{
    fonts = {
        packages = with pkgsStable; [
            (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
            ipafont
            inputs.aurebesh-fonts.defaultPackage.${system}
        ];

        fontconfig.defaultFonts = rec {
            serif = sansSerif;
            sansSerif = [ "DejaVu Sans" ];
            monospace = [ "CaskaydiaCove Nerd Font Mono" ];
            emoji = [ "Noto Color Emoji" ];
        };
    };
}
