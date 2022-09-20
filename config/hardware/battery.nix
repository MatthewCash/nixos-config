{ lib, pkgs, ... }:

let target = 80; in
{
    # Limit Battery Charge to 80%
    services.udev.extraRules = ''
        ACTION=="add", KERNEL=="asus-nb-wmi", RUN+="${pkgs.bash}/bin/bash -c 'echo ${builtins.toString (target + 1)} > /sys/class/power_supply/BAT?/charge_control_end_threshold'"
    '';

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
