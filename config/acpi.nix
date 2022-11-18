{ pkgsStable, ... }:

let batteryTarget = 80; in
{
    services.acpid = {
        enable = true;

        lidEventCommands = ''
            # If the lid is closed and charger is unplugged, suspend after 15 seconds
            [[ `cat /proc/acpi/button/lid/LID/state | ${pkgsStable.gawk}/bin/awk '{print $2}'` == "closed" ]] && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && sleep 15 && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && [[ `cat /proc/acpi/button/lid/LID/state | ${pkgsStable.gawk}/bin/awk '{print $2}'` == "closed" ]] && systemctl suspend
        '';

        acEventCommands = ''
            # If the lid is closed and charger is unplugged, suspend after 15 seconds
            sleep 1 && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && [[ `cat /proc/acpi/button/lid/LID/state | ${pkgsStable.gawk}/bin/awk '{print $2}'` == "closed" ]] && sleep 5 && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && [[ `cat /proc/acpi/button/lid/LID/state | ${pkgsStable.gawk}/bin/awk '{print $2}'` == "closed" ]] && systemctl suspend

            # Set battery limit to 80% when plugged in
            [[ `cat /sys/class/power_supply/BAT0/status` == "Charging" ]] && echo ${builtins.toString (batteryTarget + 1)} > /sys/class/power_supply/BAT?/charge_control_end_threshold
        '';
    };
}
