{ lib, pkgs, ... }:

{
    environment = {
        variables.EDITOR = lib.mkForce "$EDITOR";
        shells = with pkgs; [ zsh ];
    };
}
