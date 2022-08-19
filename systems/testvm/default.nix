{ lib, inputs }:

rec {
    hostname = "testvm";
    system = "x86_64-linux";
    kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_latest;
    ssd = false;

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}