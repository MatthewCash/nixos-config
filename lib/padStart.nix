{ lib, ... }:

let
    padStart = { str, len, padStr ? " " }:
    let
        repeat = { str, count }:
            lib.concatStringsSep "" (lib.genList (x: str) count);
        padLength = len - (lib.stringLength str);
        padding = if padLength > 0 then repeat { str = padStr; count = padLength; } else "";
    in padding + str;
in

{
    inherit padStart;
}
