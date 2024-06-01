{
    description = "NixOS and Home Manager Configuration";

    inputs.nix-inputs.url = "github:MatthewCash/nix-inputs";

    outputs = originalInputs @ { nix-inputs, ... }:
    let
        inputs = nix-inputs.outputs.inputs // builtins.removeAttrs originalInputs [ "nix-inputs" ];
        inherit (inputs) nixpkgsStable nixpkgsUnstable flake-utils;

        stableLib = nixpkgsStable.lib;

        stateVersion = "24.05";

        # Systems
        systemNames = builtins.attrNames
            (stableLib.attrsets.filterAttrs (n: v: v == "directory")
            (builtins.readDir ./systems));
        systemConfigList = builtins.map (name: {
            inherit name;
            value = import ./systems/${name} {
                inherit nixpkgsStable nixpkgsUnstable;
            } // (if stableLib.inPureEvalMode then {} else { system = builtins.currentSystem; });
        }) systemNames;
        systemConfigs = builtins.listToAttrs systemConfigList;
        buildArgs = builtins.mapAttrs (name: systemConfig:
            import ./systems/buildArgs.nix {
                inherit systemConfig inputs nixpkgsStable nixpkgsUnstable stateVersion;
            }
        ) systemConfigs;

        # NixOS Configurations
        nixosSystems = builtins.zipAttrsWith (name: both:
            let
                systemConfig = builtins.elemAt both 0;
                buildArgs = builtins.elemAt both 1;
            in
            import ./systems/buildNixos.nix (buildArgs // {
                inherit systemConfig buildArgs inputs nixpkgsStable nixpkgsUnstable stateVersion;
            })
        ) [ systemConfigs buildArgs ];
        nixosConfigurations = builtins.mapAttrs (name: system:
            system.specialArgs.systemNixpkgs.lib.nixosSystem system
        ) nixosSystems;

        # Standalone Home Manager Configurations
        homeConfigurations = builtins.zipAttrsWith (systemName: both:
            let
                systemConfig = builtins.elemAt both 0;
                buildArgs = builtins.elemAt both 1;
            in
            (import ./systems/buildHomeConfigs.nix (buildArgs // {
                inherit (systemConfig) systemNixpkgs system homeConfig;
                inherit buildArgs;
            })).standalone
        ) [ systemConfigs buildArgs];

        # NixOS Generators
        generatorFormats = builtins.attrNames inputs.nixos-generators.nixosModules;
        generatorList = builtins.map (formatName: {
            name = formatName;
            value = builtins.mapAttrs (systemName: system: inputs.nixos-generators.nixosGenerate ({
                format = formatName;
                pkgs = system.specialArgs.systemNixpkgs.legacyPackages.${system.system};
            } // system)) nixosSystems;
        }) generatorFormats;
        generators = builtins.listToAttrs generatorList;

        packages = { pkgsStable, pkgsUnstable }: let
            nix = stableLib.getExe pkgsUnstable.nix;
            eval = path: /* bash */ ''
                echo "- eval .#${path}:"
                out=$(${nix} eval --impure --raw path:.#${path})
                printf "\t$out\n"
            '';
            excludeSystems = [ "installer" ];
            testSystems = builtins.filter (name: !(builtins.elem name excludeSystems)) systemNames;
        in rec {
            inherit generators;

            apply = pkgsStable.writeShellScriptBin "apply" /* bash */ ''
                exec ${stableLib.getExe pkgsUnstable.nixos-rebuild} switch --flake path:. --use-remote-sudo $@
            '';
            full-upgrade = pkgsStable.writeShellScriptBin "full-upgrade" /* bash */ ''
                ${nix} flake update path:.
                exec ${stableLib.getExe apply}
            '';
            test = pkgsStable.writeShellScriptBin "test" /* bash */ ''
                set -e -o pipefail; shopt -s inherit_errexit

                echo "Evaluating system configurations"
                ${builtins.concatStringsSep "\n" (builtins.map (name:
                    eval "nixosConfigurations.${name}.config.system.build.toplevel"
                ) testSystems)}

                echo "Evaluating home configurations"
                ${builtins.concatStringsSep "\n" (stableLib.flatten (
                    (stableLib.mapAttrsToList (systemName: value: stableLib.mapAttrsToList (homeName: value:
                        eval "homeConfigurations.${systemName}.${homeName}"
                    ) value) homeConfigurations)
                ))}

                echo "All evaluations completed successfully!"
            '';
        };
    in
    {
        inherit nixosConfigurations homeConfigurations;
        packages = stableLib.listToAttrs (
            stableLib.forEach flake-utils.lib.defaultSystems (system:
                let
                    pkgsStable = nixpkgsStable.legacyPackages.${system};
                    pkgsUnstable = nixpkgsUnstable.legacyPackages.${system};
                in
                { name = system; value = packages { inherit pkgsStable pkgsUnstable; }; }
            )
        );
    };
}
