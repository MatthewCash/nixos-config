{
    description = "NixOS and Home Manager Configuration";

    inputs = {
        asus-wmi-screenpad = {
            url = "github:MatthewCash/asus-wmi-screenpad-module";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        aurebesh-fonts = {
            url = "github:MatthewCash/aurebesh-fonts";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        codium-theme = {
            url = "github:MatthewCash/codium-theme";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        discord-css = {
            url = "github:MatthewCash/discord-css";
            flake = false;
        };

        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        firefox-gnome-theme = {
            url = "github:rafaelmardojai/firefox-gnome-theme/beta";
            flake = false;
        };

        firefox-mods = {
            url = "github:MatthewCash/firefox-mods";
            flake = false;
        };

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        impermanence = {
            url = "github:MatthewCash/impermanence";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
            inputs.home-manager.follows = "home-manager";
        };

        kvlibadwaita = {
            url = "github:GabePoel/KvLibadwaita";
            flake = false;
        };

        lanzaboote = {
            url = "github:nix-community/lanzaboote/v1.0.0";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        mozilla-theme = {
            url = "github:MatthewCash/mozilla-theme";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        nixpkgsStable.url = "github:nixos/nixpkgs/nixos-25.11";
        nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";

        nixpak = {
            url = "github:MatthewCash/nixpak";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        plasma-manager = {
            url = "github:MatthewCash/plasma-manager";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        ragenix = {
            url = "github:yaxitech/ragenix";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        sweet-kde = {
            url = "github:EliverLara/Sweet-kde";
            flake = false;
        };

        zsh-nix-shell = {
            url = "github:MatthewCash/zsh-nix-shell";
            flake = false;
        };
    };

    outputs = inputs @ { nixpkgsStable, nixpkgsUnstable, ... }:
    let
        stableLib = nixpkgsStable.lib;

        stateVersion = "25.11";

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

        # Disk Configurations
        diskConfigurations = builtins.mapAttrs (systemName: system:
            system.pkgs.writeShellScriptBin "setup-disks" /* bash */ ''
                exec ${system.config.system.build.diskoScript}
            ''
        ) nixosConfigurations;

        # NixOS Generators
        generatorFormats = builtins.attrNames inputs.nixos-generators.nixosModules;
        generatorList = builtins.map (formatName: {
            name = formatName;
            value = builtins.mapAttrs (systemName: system: inputs.nixos-generators.nixosGenerate ({
                format = formatName;
            } // system)) nixosSystems;
        }) generatorFormats;
        generators = builtins.listToAttrs generatorList;

        packages = { pkgsStable, pkgsUnstable }: let
            nix = stableLib.getExe pkgsUnstable.nix;
            eval = path: /* bash */ ''
                echo "- eval .#${path}:"
                out=$(${nix} eval --option allow-import-from-derivation false --impure --raw path:.#${path})
                printf "\t$out\n"
            '';
            build = path: /* bash */ ''
                echo "- build .#${path}:"
                out=$(${nix} build --impure --no-link --print-out-paths path:.#${path})
                printf "\t$out\n"
            '';

            excludeSystems = [ "installer" ];
            testSystems = builtins.filter (name: !(builtins.elem name excludeSystems)) systemNames;
        in rec {
            inherit generators;

            apply = pkgsStable.writeShellScriptBin "apply" /* bash */ ''
                exec ${stableLib.getExe pkgsUnstable.nixos-rebuild} switch --flake path:. --sudo $@
            '';
            full-upgrade = pkgsStable.writeShellScriptBin "full-upgrade" /* bash */ ''
                ${nix} flake update
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
            build-test = pkgsStable.writeShellScriptBin "build-test" /* bash */ ''
                set -e -o pipefail; shopt -s inherit_errexit

                echo "Building system configurations"
                ${builtins.concatStringsSep "\n" (builtins.map (name:
                    build "nixosConfigurations.${name}.config.system.build.toplevel"
                ) testSystems)}

                echo "Building home configurations"
                ${builtins.concatStringsSep "\n" (stableLib.flatten (
                    (stableLib.mapAttrsToList (systemName: value: stableLib.mapAttrsToList (homeName: value:
                        build "homeConfigurations.${systemName}.${homeName}"
                    ) value) homeConfigurations)
                ))}

                echo "All builds completed successfully!"
            '';
        };
    in
    {
        inherit nixosConfigurations homeConfigurations diskConfigurations;

        packages = stableLib.genAttrs stableLib.systems.flakeExposed (system:
            packages {
                pkgsStable = nixpkgsStable.legacyPackages.${system};
                pkgsUnstable = nixpkgsUnstable.legacyPackages.${system};
            }
        );
    };
}
