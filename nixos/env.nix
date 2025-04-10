{ stableLib, pkgsUnstable, ... }:

let
    shells = with pkgsUnstable; [ zsh ];
in

{
    environment = {
        inherit shells;
        variables.EDITOR = stableLib.mkForce "$EDITOR";
        shellAliases = stableLib.mkForce {};
    };

    programs = builtins.listToAttrs
        (builtins.map (shell: { name = shell.pname; value.enable = true; }) shells);
}
