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

            editor.whitespace.render = {
                space = "all";
                tab = "all";
            };
            editor.whitespace.characters = {
                space = "·";
                nbsp = "⍽";
                tab = "→";
            };

            theme = "main";

            keys = import ./keybinds.nix;
        };
        
        languages = import ./languages.nix { inherit pkgs; };

        # Colors from VSCode Dark+
        themes.main = import ./theme.nix;
    };
}
