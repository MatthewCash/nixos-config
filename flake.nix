{
    description = "NixOS and Home Manager Configuration";

    inputs = {
        nixpkgsStable.url = "github:nixos/nixpkgs/nixos-23.05";
        nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";

        flake-utils.url = "github:numtide/flake-utils";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        impermanence.url = "github:nix-community/impermanence";

        ragenix = {
            url = "github:yaxitech/ragenix";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        firefox-gnome-theme = {
            url = "github:rafaelmardojai/firefox-gnome-theme";
            flake = false;
        };

        zsh-nix-shell = {
            url = "github:MatthewCash/zsh-nix-shell";
            flake = false;
        };

        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        aurebesh-fonts = {
            url = "github:MatthewCash/aurebesh-fonts";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        firefox-mods = {
            url = "github:MatthewCash/firefox-mods";
            flake = false;
        };

        tpm-fido = {
            url = "github:MatthewCash/tpm-fido";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        gnome-accent-colors = {
            url = "github:demiskp/custom-accent-colors";
            flake = false;
        };

        lanzaboote = {
            url = "github:nix-community/lanzaboote?ref=v0.3.0";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        mozilla-theme = {
            url = "github:MatthewCash/mozilla-theme";
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        kvlibadwaita = {
            url = "github:GabePoel/KvLibadwaita";
            flake = false;
        };

        asus-wmi-screenpad = {
            url = "github:MatthewCash/asus-wmi-screenpad-module";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        codium-theme = {
            url = "github:MatthewCash/codium-theme";
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };
    };

    outputs = inputs @ { nixpkgsStable, nixpkgsUnstable, flake-utils, ... }:
    let
        stableLib = nixpkgsStable.lib;

        stateVersion = "23.05";

        # Lib
        customLibs = builtins.map (name: import ./lib/${name} stableLib) (builtins.attrNames
            (stableLib.attrsets.filterAttrs (n: v: v == "regular")
            (builtins.readDir ./lib)));

        customLib = builtins.foldl' (acc: cur: acc // cur) {} customLibs;

        # NixOS Configurations
        systemNames = builtins.attrNames
            (stableLib.attrsets.filterAttrs (n: v: v == "directory")
            (builtins.readDir ./systems));
        systemConfigList = builtins.map (name: {
            inherit name;
            value = (import ./systems/${name} {
                inherit nixpkgsStable nixpkgsUnstable;
            });
        }) systemNames;
        systemConfigs = builtins.listToAttrs systemConfigList;
        systems = builtins.mapAttrs (name: systemConfig:
            import ./systems/buildSystem.nix {
                inherit systemConfig inputs nixpkgsStable nixpkgsUnstable stateVersion customLib;
            }
        ) systemConfigs;
        nixosConfigurations = builtins.mapAttrs (name: system:
            system.specialArgs.systemNixpkgs.lib.nixosSystem system
        ) systems;

        # Standalone Home Manager Configurations
        homeConfigurations = builtins.mapAttrs (systemName: systemConfig:
            (import ./systems/buildHomeConfigs.nix {
                inherit (systemConfig) systemNixpkgs system homeConfig;
                inherit inputs stateVersion customLib;
                stableLib = nixpkgsStable.lib;
                extraArgs = systems.${systemName}.specialArgs;
            }).standalone
        ) systemConfigs;

        # NixOS Generators
        # FIXME: generation fails, not enough disk space on tmpfs
        generatorFormats = builtins.attrNames inputs.nixos-generators.nixosModules;
        generatorList = builtins.map (formatName: {
            name = formatName;
            value = builtins.mapAttrs (systemName: system: inputs.nixos-generators.nixosGenerate ({
                format = formatName;
                pkgs = system.specialArgs.systemNixpkgs.legacyPackages.${system.system};
            } // system)) systems;
        }) generatorFormats;
        generators = builtins.listToAttrs generatorList;

        packages = { pkgsStable }: let
            nix = "${pkgsStable.nix}/bin/nix";
            eval = path: /* bash */ ''
                echo "- eval .#${path}:"
                out=$(${nix} eval --impure --raw path:.#${path})
                printf "\t$out\n"
            '';
        in rec {
            inherit generators;
            apply = pkgsStable.writeShellScriptBin "apply" /* bash */ ''
                exec ${pkgsStable.nixos-rebuild}/bin/nixos-rebuild switch --flake path:. --use-remote-sudo $@
            '';
            full-upgrade = pkgsStable.writeShellScriptBin "full-upgrade" /* bash */ ''
                ${nix} flake update path:.
                exec ${apply}/bin/apply
            '';
            test = pkgsStable.writeShellScriptBin "test" /* bash */ ''
                set -e -o pipefail; shopt -s inherit_errexit

                echo "Evaluating system configurations"
                ${builtins.concatStringsSep "\n" (builtins.map (name:
                    eval "nixosConfigurations.${name}.config.system.build.toplevel"
                ) systemNames)}

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
                in
                { name = system; value = packages { inherit pkgsStable; }; }
            )
        );
    };
}
