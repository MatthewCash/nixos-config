{ customLib, ... }:

let
    toHex = i: customLib.padStart {
        padStr = "0";
        len = 2;
        str = customLib.decToHex i;
    };

    rgb2hex = rgb: "#${toHex rgb.r}${toHex rgb.g}${toHex rgb.b}";
in

{
    inherit rgb2hex;
}
