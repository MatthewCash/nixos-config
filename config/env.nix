{ stableLib, pkgsUnstable, ... }:

{
    environment = {
        variables.EDITOR = stableLib.mkForce "$EDITOR";
        shells = with pkgsUnstable; [ zsh ];
    };
}
