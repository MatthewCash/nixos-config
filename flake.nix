{
    description = "NixOS and Home Manager Configuration";

    inputs = {
        nixpkgsStable.url = "nixpkgs/nixos-22.05";
        nixpkgsUnstable.url = "nixpkgs/nixos-unstable";

        home-manager = {
            url = github:nix-community/home-manager;
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        impermanence.url = github:nix-community/impermanence;

        agenix = {
            url = github:ryantm/agenix;
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        nixos-vscode-server = {
            url = github:MatthewCash/nixos-vscode-server;
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        firefox-gnome-theme = {
            url = github:rafaelmardojai/firefox-gnome-theme;
            flake = false;
        };

        agnoster-zsh-theme = {
            url = github:MatthewCash/agnoster-zsh-theme;
            flake = false;
        };

        zsh-nix-shell = {
            url = github:MatthewCash/zsh-nix-shell;
            flake = false;
        };

        nixos-generators = {
            url = github:nix-community/nixos-generators;
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        aurebesh-fonts = {
            url = github:MatthewCash/aurebesh-fonts;
            inputs.nixpkgs.follows = "nixpkgsStable";
        };
    };

    outputs = inputs @ { self, nixpkgsStable, nixpkgsUnstable, ... }:

    let
        # NixOS Configurations
        systemNames = builtins.attrNames (nixpkgsStable.lib.attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir ./systems));
        systemConfigList = builtins.map (name: {
            inherit name;
                value = (import ./systems/${name} {
                inherit (nixpkgsUnstable) lib;
                nixpkgs = nixpkgsUnstable;
            });
        }) systemNames;
        systemConfigs = builtins.listToAttrs systemConfigList;
        systems = builtins.mapAttrs (name: systemConfig:
            (import ./systems/buildSystem.nix {
                inherit (nixpkgsUnstable) lib;
                inherit systemConfig inputs;
                nixpkgs = nixpkgsUnstable;
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
    in
    {
        nixosConfigurations = systems;
        packages.x86_64-linux = generators;
    };
}