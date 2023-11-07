{ pkgsUnstable, ... }:

let
    fourTabLanguages = [
        "c" "c-sharp" "cpp" "css" "go" "html" "java" "javascript" "json" "jsx" "markdown" "nix" "rust" "tsx" "typescript" "vue"
    ];
in

{
    language-server = {
        clangd = {
            command = "${pkgsUnstable.clang-tools}/bin/clangd";
        };
        docker-langserver = {
            command = "${pkgsUnstable.dockerfile-language-server-nodejs}/bin/docker-langserver";
        };
        vscode-css-language-server = {
            command = "${pkgsUnstable.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver";
            args = [ "--stdio" ];
        };
        gopls = {
            command = "${pkgsUnstable.gopls}/bin/gopls";
        };
        vscode-html-language-server = {
            command = "${pkgsUnstable.nodePackages.vscode-html-languageserver-bin}/bin/html-languageserver";
            args = [ "--stdio" ];
        };
        vscode-json-language-server = {
            command = "${pkgsUnstable.nodePackages.vscode-json-languageserver}/bin/vscode-json-languageserver";
            args = [ "--stdio" ];
        };
        jdtls = {
            # Gets LSP from PATH because it is optional (Java is > 1GB)
            command = "jdt-language-server";
        };
        marksman = {
            command = "${pkgsUnstable.marksman}/bin/marksman";
        };
        nil = {
            command = "${pkgsUnstable.nil}/bin/nil";
        };
        omnisharp = {
            command = "${pkgsUnstable.omnisharp-roslyn}/bin/OmniSharp";
            args = [ "--languageserver" ];
        };
        pylsp = {
            command = "${pkgsUnstable.python3Packages.python-lsp-server}/bin/pylsp";
        };
        rust-analyzer = {
            command = "${pkgsUnstable.rust-analyzer}/bin/rust-analyzer";
        };
        typescript-language-server = {
            command = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
            args = [ "--stdio" ];
        };
        vuels = {
            command = "${pkgsUnstable.nodePackages.volar}/bin/vue-language-server";
        };
        yaml-language-server = {
            command = "${pkgsUnstable.yaml-language-server}/bin/yaml-language-server";
        };
    };

    language = map (name: { inherit name; indent = { tab-width = 4; unit = "    "; }; }) fourTabLanguages;
}
