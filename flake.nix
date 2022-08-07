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
            inputs.nixpkgs.follows = "nixpkgs";
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
            url = github:MatthewCash/adw-gtk3;
            flake = false;   
        };
        
        adw-gtk3 = {
            url = path:/home/matthew/code/adw-gtk3;
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs @ { self, nixpkgs, ... }:

    let
        systemNames = builtins.attrNames (nixpkgs.lib.attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir ./systems));
        systemList = builtins.map (name: 
        { 
            name = name;
            value = (import ./systems/${name} {
                inherit (nixpkgs) lib;
                inherit inputs;
            });
        }) systemNames;
        systems = builtins.listToAttrs systemList;
    in

    {
        nixosConfigurations = systems;
    };
}
