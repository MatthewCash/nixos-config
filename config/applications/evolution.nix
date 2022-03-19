{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        evolutionWithPlugins
        evolution-ews
    ];

    programs.evolution = {
        enable = true;
	    plugins = [ pkgs.evolution-ews ];
    };
}
