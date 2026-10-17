{ inputs, pkgsUnstable, persistenceHomePath, system, ... }:

let
    korsa = inputs.korsa.packages.${system}.default;

    launchKorsa = pkgsUnstable.writeShellScript "launch-korsa" ''
        export PULSE_SINK=games
        export QT_QPA_PLATFORMTHEME=kde
        exec ${korsa}/bin/korsa "$@"
    '';
in

{
    home.packages = [ korsa ];

    home.persistence."${persistenceHomePath}".directories = [
        ".config/korsa"
    ];

    xdg.desktopEntries.korsa = {
        name = "Korsa";
        comment = "Manage and launch Assetto Corsa";
        exec = "${launchKorsa}";
        terminal = false;
        categories = [ "Game" ];
    };
}
