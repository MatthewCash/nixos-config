{ pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, ... }:

{
    # TODO: move persistence option to move relevant config files

    home.persistence."${persistenceHomePath}/${name}" = stableLib.mkIf useImpermanence {
        directories = [
            ".local/share/gnome-podcasts"
            ".local/share/gnome-boxes"
            ".local/share/gnome-photos"
            ".local/share/gnome-settings-daemon"
            ".local/share/gnome-shell"
            ".local/share/org.gnome.SoundRecorder"
            ".local/share/gvfs-metadata"
            ".local/share/flatpak"
            ".local/share/backgrounds"
            ".local/share/nautilus"
            ".local/share/gnome-podcasts"
            ".local/share/authenticator"

            ".cache/gnome-boxes"
            ".cache/gnome-calculator"
            ".cache/gnome-calendar"
            ".cache/gnome-desktop-thumbnailer"
            ".cache/gnome-podcasts"
            ".cache/gnome-screenshot"
            ".cache/thumbnails"
            ".cache/org.gnome.Books"
            ".cache/org.gnome.SoundRecorder"
        ];
        files = [
            # gnome-keyring-daemon misbehaves in bindfs, symlinks are fine
            # seems to be similar to https://gitlab.gnome.org/GNOME/gnome-keyring/-/issues/84
            ".local/share/keyrings"
        ];
    };

    home.packages = with pkgsUnstable; [
        loupe
        fragments
        gvfs
        sushi
        rygel
        zenity
        snapshot
        seahorse
        nautilus
        authenticator
        foliate
        gnome-autoar
        gnome-calendar
        gnome-calculator
        caribou
        gnome-boxes
        gnome-clocks
        gnome-weather
        gnome-maps
        gnome-contacts
        gnome-characters
        gnome-sound-recorder
    ] ++ (with pkgsUnstable.gnome; [
        gnome-podcasts
        gnome-connections
        gnome-firmware
    ]);
}
