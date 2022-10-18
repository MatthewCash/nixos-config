{
    description = "NixOS and Home Manager Configuration";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";

        home-manager = {
            url = github:nix-community/home-manager;
            inputs.nixpkgs.follows = "nixpkgs";
        };

        impermanence = {
            url = github:nix-community/impermanence;
        };

        agenix = {
            url = github:ryantm/agenix;
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixos-vscode-server = {
            url = github:MatthewCash/nixos-vscode-server;
            inputs.nixpkgs.follows = "nixpkgs";
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
            inputs.nixpkgs.follows = "nixpkgs";
        };

        aurebesh-fonts = {
            url = github:MatthewCash/aurebesh-fonts;
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs @ { self, nixpkgs, ... }:

    let
        # NixOS Configurations
        systemNames = builtins.attrNames (nixpkgs.lib.attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir ./systems));
        systemConfigList = builtins.map (name: {
            inherit name;
                value = (import ./systems/${name} {
                inherit (nixpkgs) lib;
                inherit inputs;
            });
        }) systemNames;
        systemConfigs = builtins.listToAttrs systemConfigList;
        systems = builtins.mapAttrs (name: systemConfig:
            (import ./systems/buildSystem.nix {
                inherit (nixpkgs) lib;
                inherit systemConfig inputs;
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