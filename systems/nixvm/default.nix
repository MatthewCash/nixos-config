{ lib, inputs }:

rec {
    hostname = "nixvm";
    system = "x86_64-linux";
    kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_5_19;

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}