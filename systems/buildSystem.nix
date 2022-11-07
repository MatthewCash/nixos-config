{ lib, inputs, nixpkgsStable, nixpkgsUnstable, systemConfig, ... }:

let
    useHomeManager = systemConfig.useHomeManager ? true;
in

(lib.nixosSystem {
    inherit (systemConfig) system;

    specialArgs = {
        inherit (systemConfig) system hostname kernelPackages ssd vpnAddress tailscaleId;
        inherit inputs nixpkgsStable nixpkgsUnstable;
        nixpkgs = nixpkgsUnstable;
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
