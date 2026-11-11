{ pkgsUnstable, ... }:

let
    python = pkgsUnstable.python3.withPackages (pythonPackages: with pythonPackages; [
        pyside6
    ]);

    korsa-dash = pkgsUnstable.writeShellApplication {
        name = "korsa-dash";
        runtimeInputs = [ python ];
        text = ''
            export PULSE_SINK=games
            export QT_QPA_PLATFORMTHEME=kde
            exec python ${./korsa-dash.py} "$@"
        '';
    };
in

{
    home.packages = [ korsa-dash ];

    xdg.dataFile."icons/hicolor/scalable/apps/korsa-dash.svg".source = ./korsa-dash.svg;

    xdg.desktopEntries.korsa-dash = {
        name = "Korsa Dash";
        comment = "Select and launch an Assetto Corsa session";
        exec = "korsa-dash";
        icon = "korsa-dash";
        terminal = false;
        categories = [ "Game" ];
    };
}
