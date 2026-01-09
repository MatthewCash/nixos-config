{ stableLib, buildArgs, inputs, homeConfig, stateVersion, systemNixpkgs, system, systemConfig ? null, ... }:

let
    defaultImports = [
        inputs.plasma-manager.homeModules.plasma-manager

        {
            # Dummy option for a noop when not running nixos
            options.home.persistence = stableLib.mkOption {};
        }
    ];

    defaultConfig = {
        home.stateVersion = stateVersion;
        systemd.user.startServices = "sd-switch";
    };

    nixosProfiles = builtins.mapAttrs (homeName: homeConfig: stableLib.recursiveUpdate {
        imports = defaultImports ++ homeConfig;
    } defaultConfig) homeConfig;

    nixos = {
        useGlobalPkgs = true;
        users = nixosProfiles;
        extraSpecialArgs = buildArgs // {
            persistenceHomePath = "/mnt/";
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
            useImpermanence = false;
        };
        modules = defaultImports ++ homeConfig ++ [ (stableLib.recursiveUpdate {
            home = {
                username = stableLib.warnIf
                    stableLib.inPureEvalMode
                    "This expression needs to evaluate $USER and $HOME which is not allowed in pure evaluation mode. Run with --impure to fix!"
                    builtins.getEnv "USER";
                homeDirectory = builtins.getEnv "HOME";
            };
        } defaultConfig) ];
    }).activationPackage) homeConfig;
in

{
    inherit nixos standalone;
}
