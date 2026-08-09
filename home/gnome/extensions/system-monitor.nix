{ ... }:

let
    uuid = "system-monitor@nixos-config";
in

{
    xdg.dataFile."gnome-shell/extensions/${uuid}".source = ./system-monitor;
    dconf.settings."org/gnome/shell".enabled-extensions = [ uuid ];
}
