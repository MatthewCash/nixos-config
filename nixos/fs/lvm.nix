{ ... }:

{
    services.lvm = {
        boot.thin.enable = true;
        dmeventd.enable = true;
    };

    boot.initrd.services.lvm.enable = true;

    boot.extraModprobeConfig = ''
        softdep dm_mod pre: dm_thin_pool
    '';
}
