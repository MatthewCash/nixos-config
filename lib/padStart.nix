lib:
with lib;

let
    padStart ={ str, len, padStr ? " " }:
    let
        repeat = { str, count }:
            concatStringsSep "" (genList (x: str) count);
        padLength = len - (stringLength str);
        padding = if padLength > 0 then repeat { str = padStr; count = padLength; } else "";
    in padding + str;
in

{
    inherit padStart;
}
