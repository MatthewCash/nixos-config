{ pkgsStable, ... }:

let
    batteryTarget = 80;

    isLidClosed = "[[ \"$(cat /proc/acpi/button/lid/LID/state)\" == \"state:      closed\" ]]";
    isPowerConnected = "[[ \"$(cat /sys/class/power_supply/AC?/online)\" -eq 0 ]]";
    isPowerDisconnected = "[[ \"$(cat /sys/class/power_supply/AC?/online)\" -eq 0 ]]";
    sleep = "${pkgsStable.coreutils}/bin/sleep";
in
{
    services.acpid = {
        enable = true;

        lidEventCommands = ''
            # If lid is closed...
            if ${isLidClosed}; then
                # Suspend if discharging and if lid is still closed after 15 seconds
                ${isPowerDisconnected} && ${sleep} 15 && ${isPowerDisconnected} \
                    && ${isLidClosed} && ${pkgsStable.systemd}/bin/systemctl suspend
            fi
        '';

        acEventCommands = ''
            # If the lid is closed and charger is unplugged, suspend after 15 seconds
            ${sleep} 1 && ${isPowerDisconnected} \
                && ${isLidClosed} && ${sleep} 5 && ${isPowerDisconnected} \
                && ${isLidClosed} && ${pkgsStable.systemd}/bin/systemctl suspend

            # Set battery limit to 80% when plugged in
            ${isPowerConnected} \
                && echo ${builtins.toString (batteryTarget + 1)} > /sys/class/power_supply/BAT?/charge_control_end_threshold
        '';
    };
}
