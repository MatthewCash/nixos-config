{ stableLib, pkgsStable, ... }:

let
    target = 80;
    batteryTargetStr = builtins.toString (stableLib.min (target + 1) 100);
in
{
    # Limit Battery Charge
    services.udev.extraRules = ''
        ACTION=="add", KERNEL=="asus-nb-wmi", RUN+="${pkgsStable.bash}/bin/bash -c 'echo ${batteryTargetStr} > /sys/class/power_supply/BAT?/charge_control_end_threshold'"
    '';

    powerManagement.cpuFreqGovernor = stableLib.mkDefault "powersave";
}
