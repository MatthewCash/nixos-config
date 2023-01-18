{ pkgsUnstable, ... }:

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
    }
    {
        name = "cpp";
        language-server.command = "${pkgsUnstable.clang-tools}/bin/clangd";
    }
    {
        name = "css";
        language-server.command = "${pkgsUnstable.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver";
    }
    {
        name = "go";
        language-server.command = "${pkgsUnstable.gopls}/bin/gopls";
    }
    {
        name = "html";
        language-server.command = "${pkgsUnstable.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver";
    }
    {
        name = "java";
        language-server.command = "${pkgsUnstable.jdt-language-server}/bin/jdt-language-server";
        language-server.args = [ "-configuration" ".jdtls/config" "-data" ".jdtls/data" ];
    }
    {
        name = "javascript";
        language-server.command = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
    }
    {
        name = "json";
        language-server.command = "${pkgsUnstable.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver";
    }
    {
        name = "jsx";
        language-server.command = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
    }
    {
        name = "nix";
        language-server.command = "${pkgsUnstable.rnix-lsp}/bin/rnix-lsp";
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
    }
    {
        name = "vue";
        language-server.command = "${pkgsUnstable.nodePackages.vls}/bin/vls";
    }
]
