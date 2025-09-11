{ pkgsUnstable, stableLib, config, ... }:

{
    extensions = with pkgsUnstable.vscode-extensions; [
        jnoortheen.nix-ide
        mkhl.direnv
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        redhat.java
        ms-vscode.powershell
        ms-python.python
        detachhead.basedpyright
        charliermarsh.ruff
        rust-lang.rust-analyzer
        bungcip.better-toml
        llvm-vs-code-extensions.vscode-clangd
        myriad-dreamin.tinymist
        redhat.vscode-yaml
        editorconfig.editorconfig
        svelte.svelte-vscode
        vue.volar
        bradlc.vscode-tailwindcss
        streetsidesoftware.code-spell-checker
    ];
    settings = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;

        "files.exclude" = {
            "node_modules/" = true;
            "**/__pycache__" = true;
        };

        "[java]"."editor.defaultFormatter" = "redhat.java";
        "java.jdt.ls.java.home" = "${pkgsUnstable.jdk}/lib/openjdk";
        "java.import.gradle.home" = "${pkgsUnstable.gradle}/lib/gradle";
        "java.configuration.updateBuildConfiguration" = "automatic";
        "java.format.settings.url" = "${config.xdg.configHome}/java/java-formatter.xml";

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

        "clangd.path" = stableLib.getExe' pkgsUnstable.clang-tools "clangd";

        "[typst]"."editor.defaultFormatter" = "myriad-dreamin.tinymist";

        "[yaml]"."editor.defaultFormatter" = "redhat.vscode-yaml";
        "redhat.telemetry.enabled" = false;

        "[toml]"."editor.defaultFormatter" = "tamasfe.even-better-toml";
    };
}
