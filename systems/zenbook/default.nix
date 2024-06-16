{ nixpkgsUnstable, ... }:

rec {
    hostname = "zenbook";
    system = "x86_64-linux";
    systemNixpkgs = nixpkgsUnstable;
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_6_9;
    ssd = true;
    vpnAddress = "10.0.0.9";
    tailscaleId = "zeta";
    unfreePkgs = [ "steam" "steam-original" ];
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
