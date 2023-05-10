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

    nixosConfig = builtins.toString ./config;
    homeConfig.main = builtins.toString ./home;
}
