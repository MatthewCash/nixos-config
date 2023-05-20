args @ { pkgsStable, stableLib, ... }:

let
    common = import ./common.nix args;

    extensions = common.extensions;
    settings = common.settings;

    extensionPath = ".vscodium-server/extensions";
    settingsPath = ".vscodium-server/data/Machine/settings.json";

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
