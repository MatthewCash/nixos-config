{ pkgsUnstable, stableLib, config, ... }:

{
    extensions = with pkgsUnstable.vscode-extensions; [
        jnoortheen.nix-ide
        dbaeumer.vscode-eslint
        github.vscode-pull-request-github
        eamodio.gitlens
        esbenp.prettier-vscode
        redhat.java
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
        ms-vscode.powershell
        ms-python.python
        ms-pyright.pyright
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        llvm-vs-code-extensions.vscode-clangd
        nvarner.typst-lsp
        redhat.vscode-yaml
        editorconfig.editorconfig
        svelte.svelte-vscode
        vue.volar
        bradlc.vscode-tailwindcss
    ];
    settings = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "files.exclude" = {
            "node_modules/" = true;
            "**/__pycache__" = true;
        };

        "[java]"."editor.defaultFormatter" = "redhat.java";
        "java.jdt.ls.java.home" = "${pkgsUnstable.jdk}/lib/openjdk";
        "java.import.gradle.home" = "${pkgsUnstable.gradle}/lib/gradle";
        "java.configuration.updateBuildConfiguration" = "automatic";
        "java.format.settings.url" = "${config.xdg.configHome}/java/java-formatter.xml";

        "[csharp]"."editor.defaultFormatter" = "ms-dotnettools.csharp";
        "dotnet.dotnetPath" = "${pkgsUnstable.dotnet-sdk}/share/dotnet";
        "dotnetAcquisitionExtension.sharedExistingDotnetPath" = "${pkgsUnstable.dotnet-sdk}/share/dotnet";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = stableLib.getExe pkgsUnstable.nil;

        "powershell.powerShellAdditionalExePaths.main" = stableLib.getExe pkgsUnstable.powershell;

        "[python]"."editor.defaultFormatter" = "ms-python.python";
        "python.formatting.autopep8Path" = stableLib.getExe pkgsUnstable.python3Packages.autopep8;

        "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "rust-analyzer.check.overrideCommand" = [
            (stableLib.getExe pkgsUnstable.clippy)
            "check"
            "--message-format=json"
        ];
        "rust-analyzer.rustfmt.overrideCommand" = [ (stableLib.getExe pkgsUnstable.rustfmt) "--edition" "2024" ];
        "rust-analyzer.inlayHints.typeHints.enable" = false;

        "clangd.path" = stableLib.getExe' pkgsUnstable.clang-tools "clangd";

        "[typst]"."editor.defaultFormatter" = "nvarner.typst-lsp";

        "[yaml]"."editor.defaultFormatter" = "redhat.vscode-yaml";
        "redhat.telemetry.enabled" = false;
    };
}
