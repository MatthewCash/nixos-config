{ ... }:

{
    services.lvm = {
        boot.thin.enable = true;
        dmeventd.enable = true;
    };

    boot.initrd.services.lvm.enable = true;
}
