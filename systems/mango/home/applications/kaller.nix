{ inputs, persistenceHomePath, pkgsUnstable, system, ... }:

{
    home.packages = [ inputs.kaller.packages.${system}.default ];

    systemd.user.services.kaller-phone-connect = {
        Unit = {
            Description = "Connect Galaxy S22 for Kaller";
            After = [ "graphical-session.target" "wireplumber.service" ];
            PartOf = [ "graphical-session.target" ];
        };

        Service = {
            Type = "oneshot";
            TimeoutStartSec = 60;
            ExecStart = pkgsUnstable.writeShellScript "kaller-phone-connect" ''
                set -euo pipefail
                export LC_ALL=C
                hfp_connected() {
                    ${pkgsUnstable.systemd}/bin/busctl --user --timeout=5 --json=short call \
                        org.pipewire.Telephony /org/pipewire/Telephony \
                        org.freedesktop.DBus.ObjectManager GetManagedObjects \
                        | ${pkgsUnstable.jq}/bin/jq -e \
                            --arg address '78:F2:38:A7:8B:C1' \
                            '.data[0] | any(.[]; .["org.pipewire.Telephony.AudioGateway1"].Address.data == $address)' \
                            > /dev/null
                }

                if hfp_connected; then
                    exit 0
                fi

                # Find the paired device across all adapters; their ordering can
                # change at boot, and bluetoothctl only searches its default.
                device_path=$(${pkgsUnstable.systemd}/bin/busctl --system --timeout=5 --json=short call \
                    org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects \
                    | ${pkgsUnstable.jq}/bin/jq -er \
                        --arg address '78:F2:38:A7:8B:C1' \
                        '[.data[0] | to_entries[]
                          | select(.value["org.bluez.Device1"].Address.data == $address
                              and .value["org.bluez.Device1"].Paired.data == true)
                          | .key][0] // empty')

                ${pkgsUnstable.systemd}/bin/busctl --system --timeout=20 call \
                    org.bluez "$device_path" org.bluez.Device1 ConnectProfile \
                    s 0000111f-0000-1000-8000-00805f9b34fb
                # PipeWire may publish the gateway shortly after BlueZ returns.
                for attempt in 1 2 3; do
                    if hfp_connected; then
                        exit 0
                    fi
                    ${pkgsUnstable.coreutils}/bin/sleep 1
                done
                echo "HFP connected but the phone is not available in PipeWire" >&2
                exit 1
            '';
        };
    };

    systemd.user.timers.kaller-phone-connect = {
        Unit = {
            Description = "Keep Galaxy S22 connected for Kaller";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
        };

        Timer = {
            OnActiveSec = 10;
            OnUnitInactiveSec = 30;
            AccuracySec = 1;
        };

        Install.WantedBy = [ "graphical-session.target" ];
    };

    programs.plasma.configFile.fonerrc.General = {
        CloseToTray = true;
        StartMinimised = true;
        AutoLoadContacts = true;
    };

    programs.plasma.configFile."foner.notifyrc"."Event\\/contacts-loaded".Action = "None";
    programs.plasma.configFile."foner.notifyrc"."Event\\/phone-connected".Action = "None";

    home.persistence."${persistenceHomePath}".directories = [
        ".local/share/foner"
    ];
}
