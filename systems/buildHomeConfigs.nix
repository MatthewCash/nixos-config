{ stableLib, inputs, homeConfig, stateVersion, extraArgs, systemNixpkgs, system, customLib, useImpermanence }:

let
    defaultImports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.tpm-fido.nixosModules.home-manager.default
    ];

    defaultConfig = {
        home.stateVersion = stateVersion;
        systemd.user.startServices = "sd-switch";
    };

    nixosProfiles = builtins.mapAttrs (homeName: homeConfig: stableLib.recursiveUpdate {
        imports = defaultImports ++ homeConfig;
        home.persistence."/mnt/home/${homeName}".allowOther = true;
    } defaultConfig) homeConfig;

    nixos = {
        useGlobalPkgs = true;
        users = nixosProfiles;
        extraSpecialArgs = extraArgs // {
            persistenceHomePath = "/mnt/home";
            inherit useImpermanence;
        };
    };

    standalone = builtins.mapAttrs (homeName: homeConfig: (inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = systemNixpkgs.legacyPackages.${system};
        extraSpecialArgs = extraArgs // {
            persistenceHomePath = "none";
            useImpermanence = false;
            name = builtins.getEnv "USER";
        };
        modules = defaultImports ++ homeConfig ++ [ (stableLib.recursiveUpdate {
            home = {
                username =
                    stableLib.warnIf
                    stableLib.inPureEvalMode
                    "This expression needs to evaluate $USER,$HOME which is not allowed in pure evaluation mode. Run with --impure to fix!"
                    builtins.getEnv "USER";
                homeDirectory = builtins.getEnv "HOME";
            };
        } defaultConfig) ];
    }).activationPackage) homeConfig;
in

{
    inherit nixos standalone;
}
