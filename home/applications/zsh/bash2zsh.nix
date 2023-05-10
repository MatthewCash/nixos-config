{ pkgsUnstable, ... }:

let
    zsh = "${pkgsUnstable.zsh}/bin/zsh";
in

{
    programs.bash = {
        enable = true;
        initExtra = "SHELL=${zsh} exec ${zsh}";
    };
}
