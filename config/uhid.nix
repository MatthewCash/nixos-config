{ ... }:

{
    users.extraGroups."uhid".gid = 846;

    services.udev.extraRules = ''
        KERNEL=="uhid", SUBSYSTEM=="misc", GROUP="uhid", MODE="0660"
    '';

    boot.kernelModules = [ "uhid" ];
}
