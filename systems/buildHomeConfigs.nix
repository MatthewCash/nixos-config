{ stableLib, buildArgs, inputs, homeConfig, stateVersion, systemNixpkgs, system, systemConfig ? null, ... }:

let
    defaultImports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        inputs.tpm-fido.nixosModules.home-manager.default
        inputs.plasma-manager.homeManagerModules.plasma-manager
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
        extraSpecialArgs = buildArgs // {
            persistenceHomePath = "/mnt/home";
            inherit (buildArgs) useImpermanence;
            inherit systemConfig;
        };
    };

    standalone = builtins.mapAttrs (homeName: homeConfig: (inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = systemNixpkgs.legacyPackages.${system};
        extraSpecialArgs = buildArgs // {
            persistenceHomePath = "none";
            name = builtins.getEnv "USER";
            systemConfig = null;
            inherit (buildArgs) useImpermanence;
        };
        modules = defaultImports ++ homeConfig ++ [ (stableLib.recursiveUpdate {
            home = {
                persistence."none/${homeName}".allowOther = false; # Doesn't do anything, just prevents a warning
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
