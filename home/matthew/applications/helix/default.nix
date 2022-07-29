{ pkgs, ... }:

{
    programs.helix = {
        enable = true;
        settings = {
            editor.line-number = "relative";
            editor.idle-timeout = 0;
            editor.completion-trigger-len = 1;

            editor.cursor-shape = {
                insert = "bar";
            };

            theme = "main";

            keys = import ./keybinds.nix;
        };

        # Colors from VSCode Dark+
        themes.main = import ./theme.nix;
    };

    home.packages = with pkgs; with nodePackages; [
        clang-tools
        rnix-lsp
        lldb
        typescript-language-server
        vscode-css-languageserver-bin
        vscode-html-languageserver-bin
        vscode-json-languageserver
        rust-analyzer
        vls
        omnisharp-roslyn
        jdt-language-server
        gopls
        taplo-lsp
    ];
}
