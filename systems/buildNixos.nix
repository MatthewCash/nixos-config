{ buildArgs, inputs, nixpkgsStable, nixpkgsUnstable, systemConfig, stateVersion, customLib, pkgsStable, pkgsUnstable, stableLib, unstableLib, accentColor, ... }:

let
    kernelPackages = systemConfig.kernelPackages or nixpkgsUnstable.legacyPackages.${systemConfig.system}.linuxPackages;
    persistPath = systemConfig.persistPath or "/mnt/persist";
    homeMountPath = systemConfig.persistPath or "/mnt/home";
    batteryChargeLimit = systemConfig.batteryChargeLimit or 100;

    extraArgs = {
        inherit (systemConfig) system systemNixpkgs hostname users;
        inherit inputs nixpkgsStable nixpkgsUnstable kernelPackages persistPath homeMountPath batteryChargeLimit stateVersion customLib pkgsStable pkgsUnstable stableLib unstableLib accentColor;
    };
in

{
    inherit (systemConfig) system;

    specialArgs = extraArgs;

    pkgs = import systemConfig.systemNixpkgs buildArgs.nixpkgsArgs;

    modules = [
        inputs.ragenix.nixosModules.default

        inputs.impermanence.nixosModule

        inputs.home-manager.nixosModules.home-manager

        inputs.lanzaboote.nixosModules.lanzaboote

        inputs.disko.nixosModules.default

        ({ config, ... }: {
            system.stateVersion = stateVersion;

            environment.persistence.${persistPath}.enableWarnings = false;

            home-manager = (import ./buildHomeConfigs.nix (buildArgs // {
                inherit (systemConfig) systemNixpkgs system homeConfig;
                inherit buildArgs inputs stateVersion extraArgs customLib;
                systemConfig = config;
            })).nixos;

            systemd.services = stableLib.mapAttrs' (user: _: stableLib.nameValuePair
                "home-manager-${user}" { serviceConfig.RemainAfterExit = "yes"; }
            ) systemConfig.homeConfig;

            systemd.targets.home-files.wantedBy = stableLib.mkForce []; # prevent being pulled in by local-fs.target
        })

        (args: builtins.foldl'
            (a: b: stableLib.recursiveUpdate a b)
            {}
            (builtins.map (path: stableLib.filterAttrs (n: v: n == "disko") (import path args)) systemConfig.nixosConfig)
        )
    ] ++ (builtins.map
        (path: args: builtins.removeAttrs (import path args) [ "disko" ])
        systemConfig.nixosConfig
    );
}
