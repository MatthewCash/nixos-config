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

            keys.normal = {
                "q" = "no_op"; # Q
                "w" = "no_op"; # W
                "f" = "no_op"; # E
                "p" = "replace"; # R
                "b" = ":x"; # T
                "B" = ":q!";
                "j" = "yank"; # Y
                "l" = "undo"; # U
                "L" = "redo";
                "u" = "move_line_up"; # I
                "U" = "half_page_up";
                "y" = "open_below"; # O
                "Y" = "open_above";
                ";" = "no_op"; # P
                "[" = "no_op"; # [
                "]" = "no_op"; # ]
                "\\\\" = "no_op"; # \
                "a" = "append_mode"; # A
                "A" = "append_to_line";
                "r" = "unindent"; # S
                "s" = "indent"; # D
                "t" = "insert_mode"; # F
                "T" = "prepend_to_line";
                "g" = "paste_after"; # G
                "m" = "delete_selection"; # H
                "M" = [ "extend_to_line_bounds" "delete_selection" ];
                "n" = "move_char_left"; # J
                "N" = "move_prev_word_start";
                "e" = "move_line_down"; # K
                "E" = "half_page_down";
                "i" = "move_char_right"; # L
                "I" = "move_next_word_end";
                "o" = "no_op"; # ;
                "'" = "no_op"; # '
                "x" = "search"; # Z
                "c" = "no_op"; # X
                "d" = "no_op"; # C
                "v" = "select_mode"; # V
                "z" = "no_op"; # B
                "k" = "no_op"; # N
                "h" = "no_op"; # M
                "," = "no_op"; # ,
                "." = "no_op"; # .
                "/" = "no_op"; # /
            };
        };

        # Colors from VSCode Dark+
        themes.main = let 
            white = "#ffffff";
            orange = "#ce9178";
            gold = "#d7ba7d";
            gold2 = "#cca700";
            pale_green = "#b5cea8";
            dark_green = "#6A9955";
            light_gray = "#d4d4d4";
            light_gray2 = "#c6c6c6";
            light_gray3 = "#eeeeee";
            dark_gray = "#858585";
            dark_gray2 = "#1e1e1e";
            dark_gray3 = "#282828";
            blue = "#007acc";
            blue2 = "#569CD6";
            blue3 = "#6796E6";
            light_blue = "#75beff";
            dark_blue = "#264f78";
            dark_blue2 = "#094771";
            red = "#ff1212";

            type = "#4EC9B0";
            special = "#C586C0";
            variable = "#9CDCFE";
            fn_declaration = "#DCDCAA";
            constant = "#4FC1FF";

            background = "#1e1e1e";
            text = "#d4d4d4";
            cursor = "#a6a6a6";
            widget = "#252526";
            borders = "#323232";
        in {
            "namespace" = { fg = type; };
            "module" = { fg = type; };

            "type" = { fg = type; };
            "type.builtin" = { fg = type; };
            "type.enum.variant" = { fg = constant; };
            "constructor" = { fg = type; };
            "variable.other.member" = { fg = variable; };

            "keyword" = { fg = blue2; };
            "keyword.directive" = { fg = blue2; };
            "keyword.control" = { fg = special; };
            "label" = { fg = blue2; };
            "tag" = blue2;

            "special" = { fg = text; };
            "operator" = { fg = text; };

            "punctuation" = { fg = text; };
            "punctuation.delimiter" = { fg = text; };

            "variable" = { fg = variable; };
            "variable.parameter" = { fg = variable; };
            "variable.builtin" = { fg = blue2; };
            "constant" = { fg = constant; };
            "constant.builtin" = { fg = blue2; };

            "function" = { fg = fn_declaration; };
            "function.builtin" = { fg = fn_declaration; };
            "function.macro" = { fg = blue2; };
            "attribute" = { fg = fn_declaration; };

            "comment" = { fg = dark_green; };

            "string" = { fg = orange; };
            "constant.character" = { fg = orange; };
            "string.regexp" = { fg = gold; };
            "constant.numeric" = { fg = pale_green; };
            "constant.character.escape" = { fg = gold; };

            "markup.heading" = { fg = blue2; modifiers = ["bold"]; };
            "markup.list" = blue3;
            "markup.bold" = { fg = blue2; modifiers = ["bold"]; };
            "markup.italic" = { modifiers = ["italic"]; };
            "markup.link.url" = { modifiers = ["underlined"]; };
            "markup.link.text" = orange;
            "markup.quote" = dark_green;
            "markup.raw" = orange;

            "diff.plus" = { fg = pale_green; };
            "diff.delta" = { fg = gold; };
            "diff.minus" = { fg = red; };

            "ui.background" = { fg = light_gray; bg = "none"; };

            "ui.window" = { bg = widget; };
            "ui.popup" = { bg = widget; };
            "ui.help" = { bg = widget; };
            "ui.menu" = { bg = widget; };
            "ui.menu.selected" = { bg = dark_blue2; };

            "ui.cursor" = { fg = cursor; modifiers = ["reversed"]; };
            "ui.cursor.primary" = { fg = cursor; modifiers = ["reversed"]; };
            "ui.cursor.match" = { bg = "#3a3d41"; modifiers = ["underlined"]; };

            "ui.selection" = { bg = "#3a3d41"; };
            "ui.selection.primary" = { bg = dark_blue; };

            "ui.linenr" = { fg = dark_gray; };
            "ui.linenr.selected" = { fg = light_gray2; };

            "ui.cursorline.primary" = { bg = dark_gray3; };
            "ui.statusline" = { fg = white; bg = blue; };
            "ui.statusline.inactive" = { fg = white; bg = blue; };

            "ui.text" = { fg = text; };
            "ui.text.focus" = { fg = white; };

            "ui.virtual.whitespace" = { fg = dark_gray; };
            "ui.virtual.ruler" = { bg = borders; };

            "warning" = { fg = gold2; };
            "error" = { fg = red; };
            "info" = { fg = light_blue; };
            "hint" = { fg = light_gray3; };

            "diagnostic" = { modifiers = ["underlined"]; };
        };
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
