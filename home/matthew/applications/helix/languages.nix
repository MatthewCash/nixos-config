{ pkgs, ... }:

[
    {
        name = "c";
        language-server.command = "${pkgs.clang-tools}/bin/clangd";
    }
    {
        name = "c-sharp";
        language-server.command = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";
    }
    {
        name = "cpp";
        language-server.command = "${pkgs.clang-tools}/bin/clangd";
    }
    {
        name = "css";
        language-server.command = "${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver";
    }
    {
        name = "go";
        language-server.command = "${pkgs.gopls}/bin/gopls";
    }
    {
        name = "html";
        language-server.command = "${pkgs.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver";
    }
    {
        name = "java";
        language-server.command = "${pkgs.jdt-language-server}/bin/jdt-language-server";
        language-server.args = [ "-configuration" ".jdtls/config" "-data" ".jdtls/data" ];
    }
    {
        name = "javascript";
        language-server.command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
    }
    {
        name = "json";
        language-server.command = "${pkgs.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver";
    }
    {
        name = "jsx";
        language-server.command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
    }
    {
        name = "nix";
        language-server.command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
    }
    {
        name = "rust";
        language-server.command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    }
    {
        name = "tsx";
        language-server.command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
    }
    {
        name = "typescript";
        language-server.command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
    }
    {
        name = "vue";
        language-server.command = "${pkgs.nodePackages.vls}/bin/vls";
    }
]
