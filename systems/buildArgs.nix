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

    customLibs = builtins.foldl'
        (customLibs: name: customLibs // { ${name} = import ../lib/${name}; })
        {}
        (builtins.attrNames
            (stableLib.attrsets.filterAttrs (n: v: v == "regular") (builtins.readDir ../lib))
        );

    fix = c: let
        pkgs = pkgsStable;
        lib = stableLib;
        customLib = {};
        x = builtins.foldl'
            (a: b: a // b)
            {}
            (stableLib.attrsets.mapAttrsToList (libFileName: f: builtins.mapAttrs
                (funcName: _: (c.${libFileName} { inherit inputs pkgs lib; customLib = x; }).${funcName})
                (f { inherit pkgs lib inputs customLib; }) # Dummy args so argument destructuring still works
            ) c);
    in x;
    customLib = fix customLibs;

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
