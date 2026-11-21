{ ... }:

{
    boot = {
        kernelModules = [ "kvm-intel" ];

        extraModprobeConfig = ''
            options kvm_intel nested=1
        '';
    };

    virtualisation.kvmgt.enable = true;
}
