{ inputs, pkgsUnstable, system, ... }:

let
    acLinuxManager = inputs.ac-linux-manager.packages.${system}.default;

    launchAcLinuxManager = pkgsUnstable.writeShellScript "launch-ac-linux-manager" ''
        export PULSE_SINK=games
        export QT_QPA_PLATFORMTHEME=kde
        exec ${acLinuxManager}/bin/ac-linux-manager "$@"
    '';
in

{
    home.packages = [ acLinuxManager ];

    xdg.desktopEntries.ac-linux-manager = {
        name = "AC Linux Manager";
        comment = "Manage and launch Assetto Corsa";
        exec = "${launchAcLinuxManager}";
        terminal = false;
        categories = [ "Game" ];
    };

    xdg.configFile."autostart/ac-linux-manager.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=AC Linux Manager
        Comment=Manage and launch Assetto Corsa
        Exec=${launchAcLinuxManager}
        Terminal=false
        Categories=Game;
        X-KDE-Autostart-phase=1
    '';
}
