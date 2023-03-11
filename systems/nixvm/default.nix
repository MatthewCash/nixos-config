{ nixpkgsUnstable, ... }:

rec {
    hostname = "nixvm";
    system = "x86_64-linux";
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_6_2;
    systemNixpkgs = nixpkgsUnstable;
    accentColor = {
        h = 300;
        s = 60;
        l = 70;
    };

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}
