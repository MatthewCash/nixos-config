{ nixpkgsUnstable, ... }:

rec {
    hostname = "zenbook";
    system = "x86_64-linux";
    systemNixpkgs = nixpkgsUnstable;
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_6_1;
    ssd = true;
    vpnAddress = "10.0.0.9";
    tailscaleId = "zeta";
    pamMountUsers = [ "matthew" ];
    unfreePkgs = [ "steam" "steam-original" ];
    batteryChargeLimit = 100;
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
