{ lib, inputs, systemConfig, ... }:

let
    hostname = systemConfig.hostname;

    kernelPackages = systemConfig.kernelPackages;

    ssd = systemConfig.ssd ? false;

    useHomeManager = systemConfig.useHomeManager ? true;

    vpnAddress = systemConfig.vpnAddress;

    tailscaleId = systemConfig.tailscaleId;
in

(lib.nixosSystem {
    inherit (systemConfig) system;

    specialArgs = {
        inherit inputs hostname kernelPackages ssd vpnAddress tailscaleId;
        inherit (systemConfig) system;
    };

    modules = [
        inputs.agenix.nixosModule

        inputs.impermanence.nixosModule

        inputs.home-manager.nixosModule

        {
            home-manager = {
                useGlobalPkgs = true;
                users = import ../home/buildHomeConfigs.nix {
                    inherit lib inputs;
                    homeConfigPath = systemConfig.homeConfig;
                };
                extraSpecialArgs = {
                    persistenceHomePath = "/nix/persist/home";
                    inherit inputs;
                    inherit (systemConfig) system;
                };
            };
        }

        { system.stateVersion = "22.05"; }

    ] ++ import systemConfig.nixosConfig;
})
