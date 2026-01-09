args @ { pkgsStable, pkgsUnstable, customLib, config, stableLib, persistenceHomePath, inputs, lib, ... }:

let
    thunderbird = pkgsUnstable.thunderbird.override {
        extraPolicies = import ./policy.nix args;
    };

    dconfSettings = stableLib.optionalAttrs (config.gtk.gtk3.theme.name != null) {
        "org/gnome/desktop/interface".gtk-theme = config.gtk.gtk3.theme.name;
    };

    dconfDb = customLib.generateDconfDb dconfSettings;

    wrappedThunderbird = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; } {
        config = { sloth, ... }: rec {
            app.package = thunderbird;
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.gnome.SessionManager" = "talk";
                "org.gtk.vfs.*" = "talk";
                "org.freedesktop.Notifications" = "talk";
                "org.mozilla.thunderbird_default.*" = "own";
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            flatpak.session-helper.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bind.rw = [
                    (sloth.concat' sloth.homeDir "/.thunderbird")
                    (sloth.concat' sloth.xdgCacheHome "/thunderbird")
                    (sloth.concat' sloth.runtimeDir "/gvfs")
                    (sloth.concat' sloth.runtimeDir "/gvfsd")
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                ];
                bind.dev = [
                    "/sys/class/hidraw"
                    "/sys/devices/virtual/misc/uhid"
                    (sloth.realpath (sloth.concat' sloth.runtimeDir "/tpm-fido-hidrawnode"))
                ];
                bind.ro = [
                    "/etc/fonts"
                    [ ("${config.gtk.gtk3.cursorTheme.package}/share/icons") (sloth.concat' sloth.xdgDataHome "/icons") ]
                    [ (builtins.toString dconfDb) (sloth.concat' sloth.xdgConfigHome "/dconf/user") ]
                    [ "${app.package}/lib/thunderbird/mozilla.cfg" "/app/etc/thunderbird/mozilla.cfg" ]
                ];
                sockets = {
                    wayland = true;
                    pipewire = true;
                    pulse = true;
                };
            };
        };
    };
in

{
    home.persistence."${persistenceHomePath}".directories = [
        ".thunderbird"
        ".cache/thunderbird"
    ];

    home.packages = [ wrappedThunderbird.config.env ];

    programs.thunderbird = {
        enable = true;
        package = pkgsUnstable.gnused; # Since Thunderbird is already wrapped (with nixpak) it is not specified here;
        profiles = {
            "main" = {
                isDefault = true;
                # TODO: port home-manager's firefox drv support to thunderbird
                # userChrome = import ./userChrome.nix args;
                # userContent = import ./userContent.nix args;
                settings = import ./settings.nix;
            };
        };
    };

    # thunderbird will overwrite xulstore everytime it is launched
    home.activation.thunderbirdConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${stableLib.getExe' pkgsUnstable.coreutils "install"} -D -m=444 ${
            pkgsStable.writeText "xulstore.json" (builtins.toJSON (import ./xul-settings.nix))
        } ".thunderbird/main/xulstore.json"
    '';

    # the home-manager module doesn't support user{Chrome,Content} from source
    home.file.".thunderbird/main/chrome/userChrome.css".source = import ./userChrome.nix args;
    home.file.".thunderbird/main/chrome/userContent.css".source = import ./userContent.nix args;
}
