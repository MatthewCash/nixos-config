{ nixpkgsUnstable, ... }:

rec {
    hostname = "zenbook";
    system = "x86_64-linux";
    systemNixpkgs = nixpkgsUnstable;
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_6_15;
    ssd = true;
    vpnAddress = "10.0.0.9";
    unfreePkgs = [ "steam" "steam-unwrapped" ];
    batteryChargeLimit = 100;
    accentColor = {
        h = 300;
        s = 60;
        l = 70;
    };

    users.matthew = {
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB" ];
        usePamMount = true;
    };

    nixosConfig = import ./nixos;
    homeConfig.matthew = import ./home;
}
