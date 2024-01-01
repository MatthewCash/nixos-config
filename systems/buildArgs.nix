{ inputs, nixpkgsStable, nixpkgsUnstable, systemConfig, stateVersion }:

let
    useImpermanence = systemConfig.useImpermanence or true;

    nixpkgsArgs = {
        localSystem = systemConfig.system;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgsStable.lib.getName pkg) (systemConfig.unfreePkgs or [ ]);
    };

    pkgsStable = import nixpkgsStable nixpkgsArgs;
    pkgsUnstable = import nixpkgsUnstable nixpkgsArgs;
    stableLib = pkgsStable.lib;
    unstableLib = pkgsUnstable.lib;

    customLibs = builtins.map
        (name: import ../lib/${name} {
            inherit inputs;
            pkgs = pkgsStable;
            lib = stableLib;
        })
        (builtins.attrNames
            (stableLib.attrsets.filterAttrs (n: v: v == "regular") (builtins.readDir ../lib))
        );

    customLib = builtins.foldl' (acc: cur: acc // cur) {} customLibs;

    accentColor = systemConfig.accentColor // {
        inherit (customLib.hsl2rgb accentColor) r g b;
        hex = customLib.rgb2hex accentColor;
    };

    buildArgs = {
        inherit (systemConfig) system;
        inherit inputs nixpkgsStable nixpkgsUnstable pkgsStable pkgsUnstable stableLib unstableLib accentColor stateVersion customLib useImpermanence nixpkgsArgs;
    };
in

buildArgs
