{ pkgsUnstable, ... }:

{
    services.tpm-fido = {
        enable = true;
        extraPackages = with pkgsUnstable; [ pinentry-gnome ];
    };
}
