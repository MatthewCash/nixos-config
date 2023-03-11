lib:
with lib;
hsl:
let
    h = hsl.h;
    s = hsl.s / 100.0;
    l = hsl.l / 100.0;

    mod = dividend: divisor:
    let
        quotient = dividend / divisor;
        quotient_floor = builtins.floor quotient;
        remainder = dividend - quotient_floor * divisor;
    in
        if divisor == 0 then
            builtins.NaN
        else if remainder == divisor then
            0.0
        else
            remainder;

    a = s * (trivial.min l (1 - l));
    f = n: let
        k = mod (n + h / 30.0) 12;
    in
        builtins.floor (255 * (l - a * (trivial.max (-1) (trivial.min (k - 3) (trivial.min 1 (9 - k))))));
    
in
    {
        r = f 0;
        g = f 8;
        b = f 4;
    }
