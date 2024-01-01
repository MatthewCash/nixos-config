args:

let
    toHex = i: (import ./padStart.nix args).padStart {
        padStr = "0";
        len = 2;
        str = (import ./decToHex.nix args).decToHex i;
    };

    rgb2hex = rgb: "#${toHex rgb.r}${toHex rgb.g}${toHex rgb.b}";
in

{
    inherit rgb2hex;
}
