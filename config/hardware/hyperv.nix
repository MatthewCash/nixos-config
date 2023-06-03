{ ... }:

{
    virtualisation.hypervGuest.enable = true;

    # Prevent old hyperv_fb driver from loading
    boot.blacklistedKernelModules = [ "hyperv_fb" ];

    boot.kernelParams = [ "video=hyperv_drm" ];
}
