{ lib, inputs }:

(import ../buildSystem.nix {
    systemConfig = rec {
        hostname = "nixvm";
        system = "x86_64-linux";
        kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_5_17;

        nixosConfig = builtins.toString ./config;
        homeConfig = builtins.toString ./home;
    };

    inherit lib inputs; 
})
