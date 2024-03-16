{ pkgsUnstable, ... }:

{
    programs.rbw = {
        enable = true;
        package = pkgsUnstable.rbw;
        settings = {
            email = "matthew@matthew-cash.com";
            pinentry = pkgsUnstable.pinentry-gnome3;
        };
    };
}
