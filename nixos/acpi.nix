{ pkgsStable, stableLib, batteryChargeLimit, ... }:

let
    batteryTargetStr = builtins.toString (stableLib.min (batteryChargeLimit + 1) 100);

    isLidClosed = "[[ \"$(cat /proc/acpi/button/lid/LID/state)\" == \"state:      closed\" ]]";
    isPowerConnected = "[[ \"$(cat /sys/class/power_supply/AC?/online)\" -eq 1 ]]";
    isPowerDisconnected = "[[ \"$(cat /sys/class/power_supply/AC?/online)\" -eq 0 ]]";
    sleep = stableLib.getExe' pkgsStable.coreutils "sleep";
    systemctl = stableLib.getExe' pkgsStable.systemd "systemctl";
in
{
    services.acpid = {
        enable = true;

        lidEventCommands = /* bash */ ''
            # If lid is closed...
            if ${isLidClosed}; then
                # Suspend if discharging and if lid is still closed after 15 seconds
                ${isPowerDisconnected} && ${sleep} 15 && ${isPowerDisconnected} \
                    && ${isLidClosed} && ${systemctl} suspend
            fi
        '';

        acEventCommands = /* bash */ ''
            # If the lid is closed and charger is unplugged, suspend after 15 seconds
            ${sleep} 1 && ${isPowerDisconnected} \
                && ${isLidClosed} && ${sleep} 5 && ${isPowerDisconnected} \
                && ${isLidClosed} && ${systemctl} suspend

            # Set battery limit when plugged in
            ${isPowerConnected} \
                && echo ${batteryTargetStr} > /sys/class/power_supply/BAT?/charge_control_end_threshold \
        '';
    };
}
