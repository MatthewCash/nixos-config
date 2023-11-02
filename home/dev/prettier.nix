{ ... }:

let
    settings = {
        trailingComma = "none";
        tabWidth = 4;
        semi = true;
        singleQuote = true;
        arrowParens = "avoid";
        indOfLine = "lf";
    };
in

{
    home.file."code/.prettierrc.json".text = builtins.toJSON settings;
}
