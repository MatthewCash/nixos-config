{ pkgsStable, pkgsUnstable, config, stableLib, useImpermanence, persistenceHomePath, name, inputs, ... }:

let
    wrappedPrismlauncher = inputs.nixpak.lib.nixpak { lib = stableLib; pkgs = pkgsStable; } {
        config = { sloth, ... }: {
            app.package = pkgsUnstable.prismlauncher;
            dbus.policies = {
                "org.freedesktop.portal.*" = "talk";
                "ca.desrt.dconf" = "talk";
                "org.a11y.Bus" = "talk";
                "org.freedesktop.Notifications" = "talk";
            };
            locale.enable = true;
            etc.sslCertificates.enable = true;
            flatpak.session-helper.enable = true;
            gpu.enable = true;
            bubblewrap = {
                bind.rw = [
                    (sloth.concat' sloth.xdgDataHome "/PrismLauncher")
                    (sloth.concat' sloth.runtimeDir "/doc") # For the Document portal
                    [(sloth.concat' sloth.xdgDataHome "/PrismLauncher/tmp") "/tmp"]
                    (sloth.concat' sloth.xdgStateHome "/nix/profile/share/Kvantum")
                    (sloth.concat' sloth.xdgStateHome "/nix/profile/lib/qt-6/plugins")
                    (sloth.concat' sloth.xdgConfigHome "/Kvantum")
                ];
                bind.ro = [
                    "/run/current-system"
                    "/etc/fonts"
                    (builtins.toString config.home-files) # Not in extraStorePaths because we do not want it recursively linked
                ];
                sockets = {
                    wayland = true;
                    x11 = true; # mc instances don't work quite right with wayland yet
                    pipewire = true;
                    pulse = true;
                };
            };
        };
    };
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = stableLib.mkIf useImpermanence [
        ".local/share/PrismLauncher"
    ];

    home.packages = [ wrappedPrismlauncher.config.env ];
}
