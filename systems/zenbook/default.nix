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
    unfreePkgs = [ "steam" "steam-original" "discord" ];

    nixosConfig = builtins.toString ./config;
    homeConfig = builtins.toString ./home;
}
