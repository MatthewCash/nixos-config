{ inputs, nixpkgsStable, nixpkgsUnstable, systemConfig }:

let
    useHomeManager = systemConfig.useHomeManager ? true;
    kernelPackages = systemConfig.kernelPackages or nixpkgsStable.legacyPackages.${systemConfig.system}.linuxPackages;

    nixpkgsArgs = {
        localSystem = systemConfig.system;
        config.allowUnfree = true;
    };

    extraArgs = rec {
        inherit (systemConfig) system hostname ssd vpnAddress tailscaleId;
        inherit inputs nixpkgsStable nixpkgsUnstable kernelPackages;
        pkgsStable = import nixpkgsStable nixpkgsArgs;
        pkgsUnstable = import nixpkgsUnstable nixpkgsArgs;
        stableLib = pkgsStable.lib;
        unstableLib = pkgsUnstable.lib;
    };
in

(systemConfig.systemNixpkgs.lib.nixosSystem {
    inherit (systemConfig) system;

    specialArgs = extraArgs;

    modules = [
        inputs.agenix.nixosModule

        inputs.impermanence.nixosModule

        inputs.home-manager.nixosModule

        {
            home-manager = {
                useGlobalPkgs = true;
                users = import ../home/buildHomeConfigs.nix {
                    inherit (extraArgs) stableLib;
                    inherit inputs;
                    homeConfigPath = systemConfig.homeConfig;
                };
                extraSpecialArgs = {
                    persistenceHomePath = "/nix/persist/home";
                } // extraArgs;
            };
        }

        { system.stateVersion = "22.11"; }

    ] ++ import systemConfig.nixosConfig;
})
