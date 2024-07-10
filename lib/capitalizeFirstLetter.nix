{ lib, ... }:

let
    capitalizeFirstLetter = str: lib.strings.toUpper (builtins.substring 0 1 str) +
        builtins.substring 1 (builtins.stringLength str) str;
in

{
    inherit capitalizeFirstLetter;
}
