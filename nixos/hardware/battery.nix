{ stableLib, pkgsStable, batteryChargeLimit, ... }:

let
    batteryTargetStr = builtins.toString (stableLib.min (batteryChargeLimit + 1) 100);
in
{
    # Limit Battery Charge
    services.udev.extraRules = ''
        ACTION=="add", KERNEL=="asus-nb-wmi", RUN+="${stableLib.getExe pkgsStable.bash} -c 'echo ${batteryTargetStr} > /sys/class/power_supply/BAT?/charge_control_end_threshold'"
    '';

    powerManagement.powertop.enable = true;
    services.power-profiles-daemon.enable = true;

    boot.kernelParams = [ "ahci.mobile_lpm_policy=3" ];
}
