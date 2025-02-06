{ accentColor, ... }:

{
    programs.fzf = {
        enable = true;
        colors = {
            hl = accentColor.hex;
            pointer = accentColor.hex;
            spinner = accentColor.hex;
        };
    };
}
