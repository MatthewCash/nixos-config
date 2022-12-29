{ nixpkgsUnstable, ... }:

rec {
    hostname = "testvm";
    system = "x86_64-linux";
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_latest;
    systemNixpkgs = nixpkgsUnstable;
    pamMountUsers = [ "matthew" ];
    ssd = false;

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}
