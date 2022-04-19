{ lib, inputs }:

(import ../buildSystem.nix {
    systemConfig = rec {
        hostname = "zenbook";
        system = "x86_64-linux";
        kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_5_17;
        ssd = true;
        vpnAddress = "10.0.0.9";

        nixosConfig = builtins.toString ./config;
        homeConfig = builtins.toString ./home;
    };

    inherit lib inputs; 
})
