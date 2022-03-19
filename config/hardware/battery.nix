{ lib, ... }:

{
    # Limit Battery Charge to 80%
    systemd.tmpfiles.rules = [
        "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 81"
    ];

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
