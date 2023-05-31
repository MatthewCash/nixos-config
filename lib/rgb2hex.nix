lib:

let
    toHex = i: (import ./padStart.nix lib).padStart {
        padStr = "0";
        len = 2;
        str = (import ./decToHex.nix lib).decToHex i;
    };

    rgb2hex = rgb: "#${toHex rgb.r}${toHex rgb.g}${toHex rgb.b}";
in

{
    inherit rgb2hex;
}