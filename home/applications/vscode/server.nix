args @ { pkgsStable, config, ... }:

let
    common = import ./common.nix args;

    dataDir = "${config.xdg.configHome}/vscodium-server";

    combinedExtensions = pkgsStable.buildEnv {
        name = "vscode-extensions";
        paths = common.extensions;
    };
in

{
    home.file = {
        "${dataDir}/extensions".source = "${combinedExtensions}/share/vscode/extensions";
        "${dataDir}/data/Machine/settings.json".text = builtins.toJSON common.settings;
    };
}
