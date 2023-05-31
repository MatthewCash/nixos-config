{ inputs, nixpkgsStable, nixpkgsUnstable, systemConfig, stateVersion, customLib }:

let
    kernelPackages = systemConfig.kernelPackages or nixpkgsStable.legacyPackages.${systemConfig.system}.linuxPackages;
    persistPath = systemConfig.persistPath or "/mnt/persist";
    homeMountPath = systemConfig.persistPath or "/mnt/home";
    batteryChargeLimit = systemConfig.batteryChargeLimit or 100;

    accentColor = systemConfig.accentColor // {
        inherit (customLib.hsl2rgb accentColor) r g b;
        hex = customLib.rgb2hex accentColor;
    };

    nixpkgsArgs = {
        localSystem = systemConfig.system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgsStable.lib.getName pkg) (systemConfig.unfreePkgs or [ ]);
    };

    extraArgs = rec {
        inherit (systemConfig) system systemNixpkgs hostname ssd vpnAddress tailscaleId users;
        inherit inputs nixpkgsStable nixpkgsUnstable kernelPackages persistPath homeMountPath batteryChargeLimit accentColor stateVersion customLib;
        pkgsStable = import nixpkgsStable nixpkgsArgs;
        pkgsUnstable = import nixpkgsUnstable nixpkgsArgs;
        stableLib = pkgsStable.lib;
        unstableLib = pkgsUnstable.lib;
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

        {
            system.stateVersion = stateVersion;

            home-manager = (import ./buildHomeConfigs.nix {
                inherit (systemConfig) systemNixpkgs system homeConfig;
                inherit inputs stateVersion extraArgs;
                stableLib = nixpkgsStable.lib;
            }).nixos;
        }
    ] ++ import systemConfig.nixosConfig;
}
