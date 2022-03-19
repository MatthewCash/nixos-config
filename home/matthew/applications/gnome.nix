{ pkgs, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".local/share/gnome-podcasts"
        ".local/share/gnome-boxes"
        ".local/share/gnome-photos"
        ".local/share/gnome-settings-daemon"
        ".local/share/gnome-shell"
        ".local/share/org.gnome.SoundRecorder"
        ".local/share/totem"
        ".local/share/gvfs-metadata"
        ".local/share/flatpak"
        ".local/share/backgrounds"
        ".local/share/keyrings"
        ".local/share/nautilus"
        ".local/share/gnome-podcasts"

        "./config/fragments"
        "./config/totem"
        "./config/gnome-control-center"
        "./config/gnome-boxes"
        "./config/gnome-session"
        "./config/eog"

        ".cache/gnome-boxes"
        ".cache/gnome-calculator"
        ".cache/gnome-calendar"
        ".cache/gnome-desktop-thumbnailer"
        ".cache/gnome-podcasts"
        ".cache/gnome-screenshot"
        ".cache/totem"
        ".cache/thumbnails"
        ".cache/org.gnome.Books"
        ".cache/org.gnome.SoundRecorder"
        ".cache/"
    ];

    home.packages = with pkgs; with gnome; [
        eog
        fragments
        totem
        gvfs
        sushi
        rygel
        zenity
        gpaste
        cheese
        caribou
        seahorse
        nautilus
        evince
        gnome-boxes
        gnome-books
        gnome-clocks
        gnome-autoar
        gnome-weather
        gnome-maps
        gnome-nettool
        gnome-contacts
        gnome-calendar
        gnome-screenshot
        gnome-characters
        gnome-calculator
        gnome-sound-recorder
        gnome-podcasts
        gnome-connections
    ];
}
