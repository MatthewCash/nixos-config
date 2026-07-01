{ ... }:

{
    xdg.desktopEntries.plasma-manager-commands.startupNotify = false;

    programs.plasma.shortcuts = {
        kwin."Window Close" = ["Alt+F4" "Meta+Q"];
        plasmashell."manage activities" = [ ];
    };
}
