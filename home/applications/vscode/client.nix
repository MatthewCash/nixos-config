args @ { pkgsUnstable, inputs, system, ... }:

let
    vscodium = (pkgsUnstable.vscodium.overrideAttrs (oldAttrs: {
         desktopItem = oldAttrs.desktopItem.override {
            icon = "vscode";
        };
    })).override {
        commandLineArgs = "--touch-events";
    };

    common = import ./common.nix args;
in

{
    programs.vscode = {
        enable = true;
        package = vscodium;
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgsUnstable.vscode-extensions; [
            inputs.codium-theme.defaultPackage.${system}
            tomoki1207.pdf
        ] ++ common.extensions;
        userSettings = common.settings // {
            "workbench.colorTheme" = "Main Theme";
            "window.titleBarStyle" = "custom";
            "editor.smoothScrolling" = true;
            "editor.cursorSmoothCaretAnimation" = "on";
            "workbench.list.smoothScrolling" = true;
            "terminal.integrated.smoothScrolling" = true;
            "editor.renderWhitespace" = "all";
            "files.trimTrailingWhitespace" = true;
            "files.insertFinalNewline" = true;
            "files.trimFinalNewlines" = true;
            "editor.wordWrap" = "on";
            "window.commandCenter" = true;
            "editor.fontFamily" = "'CaskaydiaCove Nerd Font Regular', monospace";
        };
    };
}
