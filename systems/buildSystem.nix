{ lib, inputs, systemConfig, ... }:

let
    hostname = systemConfig.hostname;

    kernelPackages = systemConfig.kernelPackages;

    ssd = systemConfig.ssd ? false;

    useHomeManager = systemConfig.useHomeManager ? true;

    vpnAddress = systemConfig.vpnAddress;
in

(lib.nixosSystem {
    system = systemConfig.system;

    specialArgs = { 
        inherit inputs hostname kernelPackages ssd vpnAddress;
    };

    modules = [
        inputs.agenix.nixosModule

        inputs.impermanence.nixosModule
        
        inputs.home-manager.nixosModule {
            home-manager = {
                useGlobalPkgs = true;
                users = import ../home/buildHomeConfigs.nix { 
                    inherit lib inputs;
                    homeConfigPath = systemConfig.homeConfig;
                };
                extraSpecialArgs = {
                    persistenceHomePath = "/nix/persist/home";
                    inherit inputs;
                };
            };
        }

        { system.stateVersion = "22.05"; }
        
    ] ++ import systemConfig.nixosConfig;
})


