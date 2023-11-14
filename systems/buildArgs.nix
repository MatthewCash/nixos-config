{ inputs, nixpkgsStable, nixpkgsUnstable, systemConfig, stateVersion, customLib }:

let
    useImpermanence = systemConfig.useImpermanence or true;

    accentColor = systemConfig.accentColor // {
        inherit (customLib.hsl2rgb accentColor) r g b;
        hex = customLib.rgb2hex accentColor;
    };

    nixpkgsArgs = {
        localSystem = systemConfig.system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgsStable.lib.getName pkg) (systemConfig.unfreePkgs or [ ]);
    };

    buildArgs = rec {
        inherit (systemConfig) system;
        inherit inputs nixpkgsStable nixpkgsUnstable accentColor stateVersion customLib useImpermanence nixpkgsArgs;
        pkgsStable = import nixpkgsStable nixpkgsArgs;
        pkgsUnstable = import nixpkgsUnstable nixpkgsArgs;
        stableLib = pkgsStable.lib;
        unstableLib = pkgsUnstable.lib;
    };
in

buildArgs
