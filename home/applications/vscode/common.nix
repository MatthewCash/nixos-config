{ pkgsUnstable, stableLib, config, ... }:

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
        ms-vscode.powershell
        ms-python.python
        ms-pyright.pyright
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
    ];
    settings = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "files.exclude" = {
            "node_modules/" = true;
            "**/__pycache__" = true;
        };

        "java.jdt.ls.java.home" = "${pkgsUnstable.jdk17_headless}/lib/openjdk";
        "java.import.gradle.home" = "${pkgsUnstable.gradle}/lib/gradle";
        "java.configuration.updateBuildConfiguration" = "automatic";
        "java.format.settings.url" = "${config.xdg.configHome}/java/java-formatter.xml";

        "[csharp]"."editor.defaultFormatter" = "ms-dotnettools.csharp";
        "omnisharp.dotnetPath" = "${pkgsUnstable.dotnet-sdk}/bin";
        "omnisharp.dotNetCliPaths" = [ "${pkgsUnstable.dotnet-sdk}/bin" ];
        "omnisharp.enableEditorConfigSupport" = false;
        "omnisharp.organizeImportsOnFormat" = true;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = stableLib.getExe pkgsUnstable.nil;

        "powershell.powerShellAdditionalExePaths.main" = stableLib.getExe pkgsUnstable.powershell;

        "[python]"."editor.defaultFormatter" = "ms-python.python";
        "python.formatting.autopep8Path" = stableLib.getExe pkgsUnstable.python3Packages.autopep8;

        "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "rust-analyzer.check.overrideCommand" = [ (stableLib.getExe pkgsUnstable.clippy) ];
        "rust-analyzer.rustfmt.overrideCommand" = [ (stableLib.getExe pkgsUnstable.rustfmt) "--edition" "2024" ];
    };
}
