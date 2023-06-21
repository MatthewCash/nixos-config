{ nixpkgsUnstable, ... }:

{
    hostname = "installer";
    system = "x86_64-linux";
    systemNixpkgs = nixpkgsUnstable;
    useImpermanence = false;
    accentColor = {
        h = 140;
        s = 35;
        l = 60;
    };

    users.main = {
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB" ];
    };

    nixosConfig = import ./config;
    homeConfig.main = import ./home;
}
