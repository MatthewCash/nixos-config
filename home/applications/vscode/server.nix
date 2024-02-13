args @ { pkgsStable, stableLib, config, ... }:

let
    common = import ./common.nix args;

    extensions = common.extensions;
    settings = common.settings;

    dataDir = "${config.xdg.configHome}/vscodium-server";
    extensionPath = "${dataDir}/extensions";
    settingsPath = "${dataDir}/data/Machine/settings.json";

    combinedExtensionsDrv = pkgsStable.buildEnv {
        name = "vscode-extensions";
        paths = extensions;
    };

    extensionsFolder = "${combinedExtensionsDrv}/share/vscode/extensions";

    addSymlinkToExtension = k: {
        "${extensionPath}/${k}".source = "${extensionsFolder}/${k}";
    };

    extensionFiles = builtins.attrNames (builtins.readDir extensionsFolder);

    extensionLinks = stableLib.mkMerge (map addSymlinkToExtension extensionFiles);
in

{
    home.file = stableLib.mkMerge [
        extensionLinks
        { ${settingsPath}.text = builtins.toJSON settings; }
    ];
}
