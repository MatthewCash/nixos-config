{ buildArgs, inputs, nixpkgsStable, nixpkgsUnstable, systemConfig, stateVersion, customLib, pkgsStable, pkgsUnstable, stableLib, unstableLib, accentColor, ... }:

let
    kernelPackages = systemConfig.kernelPackages or nixpkgsUnstable.legacyPackages.${systemConfig.system}.linuxPackages;
    persistPath = systemConfig.persistPath or "/mnt/persist";
    homeMountPath = systemConfig.persistPath or "/mnt/home";
    batteryChargeLimit = systemConfig.batteryChargeLimit or 100;

    extraArgs = {
        inherit (systemConfig) system systemNixpkgs hostname ssd vpnAddress tailscaleId users;
        inherit inputs nixpkgsStable nixpkgsUnstable kernelPackages persistPath homeMountPath batteryChargeLimit stateVersion customLib pkgsStable pkgsUnstable stableLib unstableLib accentColor;
    };
in

{
    inherit (systemConfig) system;

    specialArgs = extraArgs;

    modules = [
        inputs.ragenix.nixosModules.default

        inputs.impermanence.nixosModule

        inputs.home-manager.nixosModule

        inputs.lanzaboote.nixosModules.lanzaboote

        ({ config, ... }: {
            system.stateVersion = stateVersion;

            nixpkgs.config = buildArgs.nixpkgsArgs.config;

            environment.persistence.${persistPath}.enableWarnings = false;

            home-manager = (import ./buildHomeConfigs.nix (buildArgs // {
                inherit (systemConfig) systemNixpkgs system homeConfig;
                inherit buildArgs inputs stateVersion extraArgs customLib;
                systemConfig = config;
            })).nixos;
        })
    ] ++ systemConfig.nixosConfig;
}
