{ lib, inputs }:

rec {
    hostname = "nixvm";
    system = "x86_64-linux";
    kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_6_0;

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}