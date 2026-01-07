args @ { pkgsStable, config, ... }:

# Because this uses an REH directly from source, nix-ld is required
# make sure "nixos/ld.nix" is applied to the system!

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
