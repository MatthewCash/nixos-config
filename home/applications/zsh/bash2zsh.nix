{ pkgsUnstable, stableLib, ... }:

let
    zsh = stableLib.getExe pkgsUnstable.zsh;
in

{
    programs.bash = {
        enable = true;
        initExtra = "SHELL=${zsh} exec ${zsh}";
    };
}
