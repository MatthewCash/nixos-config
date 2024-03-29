{ pkgsUnstable, stableLib, ... }:

let
    fourTabLanguages = [
        "c" "c-sharp" "cpp" "css" "go" "html" "java" "javascript" "json" "jsx" "markdown" "nix" "rust" "tsx" "typescript" "vue"
    ];

    inherit (stableLib) getExe getExe';
in

{
    language-server = {
        clangd.command = getExe' pkgsUnstable.clang-tools "clangd";
        docker-langserver.command = getExe pkgsUnstable.dockerfile-language-server-nodejs;
        vscode-css-language-server = {
            command = getExe' pkgsUnstable.nodePackages.vscode-langservers-extracted "vscode-css-language-server";
            args = [ "--stdio" ];
        };
        gopls.command = getExe pkgsUnstable.gopls;
        vscode-html-language-server = {
            command = getExe' pkgsUnstable.nodePackages.vscode-langservers-extracted "vscode-html-language-server";
            args = [ "--stdio" ];
        };
        vscode-json-language-server = {
            command = getExe' pkgsUnstable.nodePackages.vscode-langservers-extracted "vscode-json-language-server";
            args = [ "--stdio" ];
        };
        jdtls.command = "jdtls"; # Gets LSP from PATH because it is optional (Java is > 1GB)
        marksman.command = getExe pkgsUnstable.marksman;
        nil.command = getExe pkgsUnstable.nil;
        omnisharp = {
            command = getExe pkgsUnstable.omnisharp-roslyn;
            args = [ "--languageserver" ];
        };
        pylsp.command = getExe pkgsUnstable.python3Packages.python-lsp-server;
        rust-analyzer.command = getExe pkgsUnstable.rust-analyzer;
        typescript-language-server = {
            command = getExe pkgsUnstable.nodePackages.typescript-language-server;
            args = [ "--stdio" ];
        };
        vuels = {
            command = getExe pkgsUnstable.nodePackages.volar;
            args = [ "--stdio" ];
        };
        yaml-language-server.command = getExe pkgsUnstable.yaml-language-server;
    };

    language = builtins.map (name: { inherit name; indent = { tab-width = 4; unit = "    "; }; }) fourTabLanguages;
}
