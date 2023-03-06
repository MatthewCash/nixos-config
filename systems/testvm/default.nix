{ nixpkgsUnstable, ... }:

rec {
    hostname = "testvm";
    system = "x86_64-linux";
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_latest;
    systemNixpkgs = nixpkgsUnstable;
    pamMountUsers = [ "matthew" ];
    ssd = false;
    accentColor = {
        h = 300;
        s = 60;
        l = 70;
        r = 224;
        g = 133;
        b = 224;
    };

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}
