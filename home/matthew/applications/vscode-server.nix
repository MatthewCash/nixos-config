{ pkgsStable, pkgsUnstable, stableLib, inputs, config, ... }:

let
    extensions = with pkgsUnstable.vscode-extensions; [
        jnoortheen.nix-ide
        dbaeumer.vscode-eslint
        github.vscode-pull-request-github
        eamodio.gitlens
        octref.vetur
        redhat.java
        ms-dotnettools.csharp
    ];
    settings = {
        "java.jdt.ls.java.home" = "${pkgsUnstable.jdk17_headless}/lib/openjdk";
        "java.import.gradle.home" = "${pkgsUnstable.gradle}/lib/gradle";
        "java.configuration.updateBuildConfiguration" = "automatic";
        "java.format.settings.url" = "${config.xdg.configHome}/java/java-formatter.xml";
        "omnisharp.dotnetPath" = "${pkgsUnstable.dotnet-sdk}/bin";
        "omnisharp.sdkPath" = "${pkgsUnstable.dotnet-sdk}/sdk/";
    };

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
