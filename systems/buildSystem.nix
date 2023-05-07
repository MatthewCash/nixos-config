{ inputs, nixpkgsStable, nixpkgsUnstable, systemConfig, stateVersion }:

let
    kernelPackages = systemConfig.kernelPackages or nixpkgsStable.legacyPackages.${systemConfig.system}.linuxPackages;
    pamMountUsers = systemConfig.pamMountUsers or [ ];
    persistPath = systemConfig.persistPath or "/mnt/persist";
    homeMountPath = systemConfig.persistPath or "/mnt/home";
    batteryChargeLimit = systemConfig.batteryChargeLimit or 100;

    stableLib = nixpkgsStable.lib;
    toHex = i: import ../util/padStart.nix stableLib { padStr = "0"; len = 2; str = import ../util/decToHex.nix stableLib i;};

    accentColor = systemConfig.accentColor // {
        inherit (import ../util/hsl2rgb.nix stableLib accentColor) r g b;
        hex = "#${toHex accentColor.r}${toHex accentColor.g}${toHex accentColor.b}";
    };

    nixpkgsArgs = {
        localSystem = systemConfig.system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgsStable.lib.getName pkg) (systemConfig.unfreePkgs or [ ]);
    };

    extraArgs = rec {
        inherit (systemConfig) system systemNixpkgs hostname ssd vpnAddress tailscaleId;
        inherit inputs nixpkgsStable nixpkgsUnstable kernelPackages pamMountUsers persistPath homeMountPath batteryChargeLimit accentColor stateVersion;
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
            home-manager = (import ./buildHomeConfigs.nix {
                inherit (systemConfig) systemNixpkgs system homeConfig;
                inherit stableLib inputs stateVersion extraArgs;
            }).nixos;
        }

        { system.stateVersion = stateVersion; }

    ] ++ import systemConfig.nixosConfig;
}
