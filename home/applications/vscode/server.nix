args @ { pkgsStable, pkgsUnstable, stableLib, ... }:

let
    common = import ./common.nix args;

    extensions = with pkgsUnstable.vscode-extensions; [
        jnoortheen.nix-ide
        dbaeumer.vscode-eslint
        github.vscode-pull-request-github
        eamodio.gitlens
        octref.vetur
        redhat.java
        ms-dotnettools.csharp
    ] ++ common.extensions;
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
