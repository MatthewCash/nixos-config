{ pkgs, ... }:

{
    services.acpid = {
        enable = true;

        lidEventCommands = ''
            [[ `cat /proc/acpi/button/lid/LID/state | ${pkgs.gawk}/bin/awk '{print $2}'` == "closed" ]] && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && sleep 15 && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && [[ `cat /proc/acpi/button/lid/LID/state | ${pkgs.gawk}/bin/awk '{print $2}'` == "closed" ]] && systemctl suspend
        '';

        acEventCommands = ''
            sleep 1 && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && [[ `cat /proc/acpi/button/lid/LID/state | ${pkgs.gawk}/bin/awk '{print $2}'` == "closed" ]] && sleep 5 && [[ `cat /sys/class/power_supply/BAT0/status` == "Discharging" ]] && [[ `cat /proc/acpi/button/lid/LID/state | ${pkgs.gawk}/bin/awk '{print $2}'` == "closed" ]] && systemctl suspend

            [[ `cat /sys/class/power_supply/BAT0/status` == "Charging" ]] && echo 81 > /sys/class/power_supply/BAT0/charge_control_end_threshold
        '';
    };
}
