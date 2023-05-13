{ users, ... }:

{
    users.extraGroups."uhid".gid = 846;

    services.udev.extraRules = ''
        KERNEL=="uhid", SUBSYSTEM=="misc", GROUP="uhid", MODE="0660"
    '';

    users.extraUsers = builtins.mapAttrs (name: config: { extraGroups = [ "tss" "uhid" ]; }) users;

    boot.kernelModules = [ "uhid" ];
}
