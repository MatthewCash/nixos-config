{ nixpkgsUnstable, ... }:

{
    hostname = "minimal";
    system = "x86_64-linux";
    systemNixpkgs = nixpkgsUnstable;
    accentColor = {
        h = 140;
        s = 35;
        l = 60;
    };

    users.main = {
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB" ];
    };

    nixosConfig = builtins.toString ./config;
    homeConfig.main = builtins.toString ./home;
}
