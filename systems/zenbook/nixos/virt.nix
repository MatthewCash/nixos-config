{ ... }:

{
    boot.kernelModules = [ "kvm-intel" ];

    boot.extraModprobeConfig = ''
        options kvm_intel nested=1
    '';

    virtualisation.kvmgt.enable = true;
}
