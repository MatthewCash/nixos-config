{
    description = "NixOS and Home Manager Configuration";

    inputs = {
        nixpkgsStable.url = "nixpkgs/nixos-22.11";
        nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
        flake-utils.url = github:numtide/flake-utils;

        home-manager = {
            url = github:nix-community/home-manager;
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        impermanence.url = github:nix-community/impermanence;

        agenix = {
            url = github:ryantm/agenix;
            inputs.nixpkgs.follows = "nixpkgsStable";
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

        firefox-mods = {
            url = github:MatthewCash/firefox-mods;
            flake = false;
        };

        tpm-fido = {
            url = github:MatthewCash/tpm-fido;
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        gnome-accent-colors = {
            url = github:demiskp/custom-accent-colors;
            flake = false;
        };

        lanzaboote = {
            url = github:nix-community/lanzaboote;
            inputs.nixpkgs.follows = "nixpkgsUnstable";
        };

        mozilla-theme = {
            url = github:MatthewCash/mozilla-theme;
            inputs.nixpkgs.follows = "nixpkgsStable";
        };

        kvlibadwaita = {
            url = github:GabePoel/KvLibadwaita;
            flake = false;
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

    in
    {
        nixosConfigurations = systems;
        packages = nixpkgsStable.lib.listToAttrs (nixpkgsStable.lib.forEach flake-utils.lib.defaultSystems (system:
            let pkgsStable = nixpkgsStable.legacyPackages.${system}; in
            {
                name = system;
                value.apply = pkgsStable.writeShellScriptBin "apply" /* bash */ ''
                    exec ${pkgsStable.nixos-rebuild}/bin/nixos-rebuild switch --flake path:. --use-remote-sudo $@
                '';
                value.full-upgrade = pkgsStable.writeShellScriptBin "full-upgrade" /* bash */ ''
                    ${pkgsStable.nix}/bin/nix flake update path:.
                    exec ${self.packages.${system}.apply}/bin/apply
                '';
            }
        ));
    };
}