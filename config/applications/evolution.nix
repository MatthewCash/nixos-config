{ pkgsUnstable, ... }:

{
    environment.systemPackages = with pkgsUnstable; [
        evolutionWithPlugins
        evolution-ews
    ];

    programs.evolution = {
        enable = true;
	    plugins = with pkgsUnstable; [ evolution-ews ];
    };
}
