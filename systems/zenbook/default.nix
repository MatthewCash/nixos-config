{ lib, inputs }:

rec {
    hostname = "zenbook";
    system = "x86_64-linux";
    kernelPackages = inputs.nixpkgs.legacyPackages.${system}.linuxPackages_6_0;
    ssd = true;
    vpnAddress = "10.0.0.9";
    tailscaleId = "zeta";

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}