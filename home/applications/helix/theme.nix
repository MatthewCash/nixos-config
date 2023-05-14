{ accentColor, ... }:

let
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
    "ui.statusline" = { fg = white; bg = accentColor.hex; };
    "ui.statusline.inactive" = { fg = white; bg = accentColor.hex; };

    "ui.text" = { fg = text; };
    "ui.text.focus" = { fg = white; };

    "ui.virtual.whitespace" = { fg = dark_gray; };
    "ui.virtual.ruler" = { bg = borders; };

    "warning" = { fg = gold2; };
    "error" = { fg = red; };
    "info" = { fg = light_blue; };
    "hint" = { fg = light_gray3; };

    "diagnostic" = { modifiers = ["underlined"]; };
}