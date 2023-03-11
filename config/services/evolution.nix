{ pkgsUnstable, ... }:

{
    services.gnome.evolution-data-server = {
        enable = true;
	    plugins = with pkgsUnstable; [ evolution evolution-ews ];
    };
}
