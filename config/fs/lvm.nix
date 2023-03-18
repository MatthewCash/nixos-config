{ ... }:

{
    services.lvm.boot.thin.enable = true;
    boot.initrd.services.lvm.enable = true;
}
