{ pkgsUnstable, stableLib, config, ... }:

let
    fourTabLanguages = [
        "c" "c-sharp" "cpp" "css" "go" "html" "java" "javascript" "json" "jsx" "markdown" "nix" "rust" "tsx" "typescript" "vue"
    ];
in

map (name: { inherit name; indent = { tab-width = 4; unit = "    "; }; }) fourTabLanguages ++
[
    {
        name = "c";
        language-server.command = "${pkgsUnstable.clang-tools}/bin/clangd";
    }
    {
        name = "c-sharp";
        language-server.command = "${pkgsUnstable.omnisharp-roslyn}/bin/OmniSharp";
        language-server.args = [ "--languageserver" ];
    }
    {
        name = "cpp";
        language-server.command = "${pkgsUnstable.clang-tools}/bin/clangd";
    }
    {
        name = "css";
        language-server.command = "${pkgsUnstable.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver";
        language-server.args = [ "--stdio" ];
    }
    {
        name = "go";
        language-server.command = "${pkgsUnstable.gopls}/bin/gopls";
    }
    {
        name = "html";
        language-server.command = "${pkgsUnstable.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver";
    }
    ] ++ stableLib.optional config.programs.java.enable { # Make Java optional because total size > 1GB
        name = "java";
        language-server.command = "${pkgsUnstable.jdt-language-server}/bin/jdt-language-server";
        language-server.args = [ "-configuration" ".jdtls/config" "-data" ".jdtls/data" ];
    } ++ [
    {
        name = "javascript";
        language-server.command = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
        language-server.args = [ "--stdio" ];
    }
    {
        name = "json";
        language-server.command = "${pkgsUnstable.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver";
    }
    {
        name = "jsx";
        language-server.command = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
        language-server.args = [ "--stdio" ];
    }
    {
        name = "python";
        language-server.command = "${pkgsUnstable.python3Packages.python-lsp-server}/bin/pylsp";
    }
    {
        name = "rust";
        language-server.command = "${pkgsUnstable.rust-analyzer}/bin/rust-analyzer";
    }
    {
        name = "tsx";
        language-server.command = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
    }
    {
        name = "typescript";
        language-server.command = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
        language-server.args = [ "--stdio" ];
    }
    {
        name = "vue";
        language-server.command = "${pkgsUnstable.nodePackages.vls}/bin/vls";
    }
    {
        name = "nix";
        language-server.command = "${pkgsUnstable.nil}/bin/nil";
    }
]
