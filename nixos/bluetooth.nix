{ persistPath, pkgsUnstable, ... }:

let
    bluezMidiZeroTimestampHighPatch = pkgsUnstable.fetchpatch {
        url = "https://github.com/MatthewCash/bluez/commit/7fbd901a761c4cb163a1d0ca95c9daccade9c889.patch";
        hash = "sha256-z6QGIK8LVxb4DVN7gqMPtUlW0BeaSyEZXyITebQxgNI=";
    };
in

{
    environment.persistence.${persistPath}.directories = [ "/var/lib/bluetooth" ];

    hardware.bluetooth = {
        enable = true;

        package = pkgsUnstable.bluez.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or []) ++ [ bluezMidiZeroTimestampHighPatch ];
        });
    };
}
