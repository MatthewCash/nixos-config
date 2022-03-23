{ pkgs, ... }:

{
    programs.rbw = {
        enable = true;
        package = pkgs.rbw;
        settings = {
            email = "matthew@matthew-cash.com";
        };
    };
}
