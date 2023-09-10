{ kernelPackages, ... }:

{
    boot = {
        kernelPackages = kernelPackages;

        kernel.sysctl = {
            "kernel.sysrq" = 1;
        };

        kernelParams = [
            "rd.shell=0"
            "rd.emergency=reboot"
        ];
    };
}
