{ pkgsUnstable, config, ... }:

{
    extensions = with pkgsUnstable.vscode-extensions; [
        jnoortheen.nix-ide
        dbaeumer.vscode-eslint
        github.vscode-pull-request-github
        eamodio.gitlens
        esbenp.prettier-vscode
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
        "omnisharp.dotNetCliPaths" = [ "${pkgsUnstable.dotnet-sdk}/bin" ];
        "omnisharp.enableEditorConfigSupport" = false;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgsUnstable.nil}/bin/nil";
    };
}
