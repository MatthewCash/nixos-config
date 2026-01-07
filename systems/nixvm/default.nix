{ nixpkgsUnstable, ... }:

rec {
    hostname = "nixvm";
    system = "x86_64-linux";
    kernelPackages = nixpkgsUnstable.legacyPackages.${system}.linuxPackages_latest;
    systemNixpkgs = nixpkgsUnstable;
    accentColor = {
        h = 300;
        s = 60;
        l = 70;
    };

    users.matthew = {
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB" ];
    };

    nixosConfig = import ./nixos;
    homeConfig.matthew = import ./home;
}
