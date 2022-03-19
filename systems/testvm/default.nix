{ lib, inputs }:

(import ../buildSystem.nix {
    systemConfig = rec {
        hostname = "testvm";
        system = "x86_64-linux";
        kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_5_16;
        ssd = false;

        nixosConfig = builtins.toString ./config;
        homeConfig = builtins.toString ./home;
    };

    inherit lib inputs;
})
