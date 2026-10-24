{ pkgsUnstable, persistenceHomePath, accentColor, lib, ... }:

let
    skin = import ./theme.nix { inherit pkgsUnstable accentColor; };
    guitarix = import ./package.nix { inherit pkgsUnstable skin; };
    guitarix-autolink = import ./autolink.nix { inherit pkgsUnstable; };
in

{
    home.packages = [ guitarix ];

    home.persistence."${persistenceHomePath}".directories = [
        ".config/guitarix"
    ];

    home.activation.guitarixThemeState = lib.hm.dag.entryAfter [ "writeBoundary" ] /* sh */ ''
        if [ -f ".config/guitarix/ui_rc" ]; then
            $DRY_RUN_CMD ${pkgsUnstable.gnused}/bin/sed -i 's/"ui\.skin_name": "Targeting_Computer"/"ui.skin_name": "Nebula"/' ".config/guitarix/ui_rc"
        fi
    '';

    systemd.user.services.guitarix-autolink = {
        Unit = {
            Description = "Auto-link Guitarix PipeWire ports";
            Requires = [ "pipewire.service" "wireplumber.service" ];
            After = [ "pipewire.service" "wireplumber.service" ];
            PartOf = [ "pipewire.service" ];
        };

        Service = {
            ExecStart = "${guitarix-autolink}/bin/guitarix-autolink";
            Restart = "always";
            RestartSec = 1;
        };

        Install.WantedBy = [ "default.target" ];
    };
}
