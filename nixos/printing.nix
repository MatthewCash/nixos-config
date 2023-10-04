{ pkgsStable, ... }:

{
    services.printing = {
        enable = true;
	    drivers = with pkgsStable; [ gutenprint gutenprintBin hplip ];
    };
}
