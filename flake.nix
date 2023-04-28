{
    description = "NixOS and Home Manager Configuration";

    inputs = {
        nixpkgsStable.url = "github:nixos/nixpkgs/nixos-22.11";
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

        agnoster-zsh-theme = {
            url = "github:MatthewCash/agnoster-zsh-theme";
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
            url = "github:nix-community/lanzaboote";
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

    outputs = inputs @ { self, nixpkgsStable, nixpkgsUnstable, flake-utils, ... }:
    let
        # NixOS Configurations
        systemNames = builtins.attrNames (nixpkgsStable.lib.attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir ./systems));
        systemConfigList = builtins.map (name: {
            inherit name;
            value = (import ./systems/${name} {
                inherit nixpkgsStable nixpkgsUnstable;
            });
        }) systemNames;
        systemConfigs = builtins.listToAttrs systemConfigList;
        systems = builtins.mapAttrs (name: systemConfig:
            (import ./systems/buildSystem.nix {
                inherit systemConfig inputs nixpkgsStable nixpkgsUnstable;
            })
        ) systemConfigs;

        # NixOS Generators
        generatorFormats = [ "qcow" "iso" "hyperv" ];
        generatorList = builtins.map (name: {
            inherit name;
            value = builtins.mapAttrs (configName: systemConfig: inputs.nixos-generators.nixosGenerate {
                inherit (systemConfig) system;
                format = name;
            }) systemConfigs;
        }) generatorFormats;
        generators = builtins.listToAttrs generatorList;

        packages = { system, pkgsStable }: rec {
            inherit generators;
            apply = pkgsStable.writeShellScriptBin "apply" /* bash */ ''
                exec ${pkgsStable.nixos-rebuild}/bin/nixos-rebuild switch --flake path:. --use-remote-sudo $@
            '';
            full-upgrade = pkgsStable.writeShellScriptBin "full-upgrade" /* bash */ ''
                ${pkgsStable.nix}/bin/nix flake update path:.
                exec ${apply}/bin/apply
            '';
            test = pkgsStable.writeShellScriptBin "test" /* bash */ ''
                ${builtins.concatStringsSep "\n"
                    (builtins.map
                        (name: "${pkgsStable.nixos-rebuild}/bin/nixos-rebuild dry-build --flake path:.#${name}")
                        systemNames
                    )
                }
            '';
        };
    in
    {
        nixosConfigurations = systems;
        packages = nixpkgsStable.lib.listToAttrs (
            nixpkgsStable.lib.forEach flake-utils.lib.defaultSystems (system:
                let
                    pkgsStable = nixpkgsStable.legacyPackages.${system};
                in
                { name = system; value = packages { inherit system pkgsStable; }; }
            )
        );
    };
}