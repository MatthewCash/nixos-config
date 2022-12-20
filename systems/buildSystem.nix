{ inputs, nixpkgsStable, nixpkgsUnstable, systemConfig }:

let
    useHomeManager = systemConfig.useHomeManager ? true;
    kernelPackages = systemConfig.kernelPackages or nixpkgsStable.legacyPackages.${systemConfig.system}.linuxPackages;
    pamMountUsers = systemConfig.pamMountUsers or [ ];
    persistPath = systemConfig.persistPath or "/mnt/persist";
    homeMountPath = systemConfig.persistPath or "/mnt/home";

    nixpkgsArgs = {
        localSystem = systemConfig.system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgsStable.lib.getName pkg) (systemConfig.unfreePkgs or [ ]);
    };

    extraArgs = rec {
        inherit (systemConfig) system hostname ssd vpnAddress tailscaleId;
        inherit inputs nixpkgsStable nixpkgsUnstable kernelPackages pamMountUsers persistPath homeMountPath;
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
                    persistenceHomePath = "/mnt/home";
                } // extraArgs;
            };
        }

        { system.stateVersion = "22.11"; }

    ] ++ import systemConfig.nixosConfig;
})
