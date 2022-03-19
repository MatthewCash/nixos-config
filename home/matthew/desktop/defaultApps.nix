{ ... }:

{
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "application/pdf" = [ "org.gnome.Evince.desktop" ];
            "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
            "x-scheme-handler/mailto" = [ "userapp-Evolution-RARTF1.desktop" ];
        };	
    };
}
