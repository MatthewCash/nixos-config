{ inputs, homeConfig, stateVersion }:

builtins.mapAttrs (homeName: homeConfigPath: {
    imports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.tpm-fido.nixosModules.home-manager.default
    ] ++ import homeConfigPath;

    home.persistence."/mnt/home/${homeName}".allowOther = true;
    systemd.user.startServices = "sd-switch";
    home.stateVersion = stateVersion;
}) homeConfig
