{ kernelPackages, ... }:

{
    boot.kernelPackages = kernelPackages;

    boot.kernel.sysctl = {
        "kernel.sysrq" = 1;
    };
}
