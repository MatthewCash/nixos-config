{ nixpkgsUnstable, ... }:

rec {
    hostname = "nixvm";
    system = "x86_64-linux";
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_6_0;
    systemNixpkgs = nixpkgsUnstable;

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}
