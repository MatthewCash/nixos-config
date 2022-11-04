{ lib, nxipkgs }:

rec {
    hostname = "nixvm";
    system = "x86_64-linux";
    kernelPackages = nixpkgs.legacyPackages.${system}.linuxPackages_6_0;

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}