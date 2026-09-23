{ users, ... }:

{
    users.extraGroups."uhid".gid = 846;

    services.udev.extraRules = ''
        KERNEL=="uhid", SUBSYSTEM=="misc", GROUP="uhid", MODE="0660"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0003:15D9:0A37.*", SYMLINK+="tpm-fido-hidrawnode"
    '';

    users.extraUsers = builtins.mapAttrs (name: config: { extraGroups = [ "tss" "uhid" ]; }) users;

    boot.kernelModules = [ "uhid" ];
}
