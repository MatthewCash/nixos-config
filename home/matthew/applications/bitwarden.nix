{ pkgsStable, ... }:

{
    programs.rbw = {
        enable = true;
        package = pkgsStable.rbw;
        settings = {
            email = "matthew@matthew-cash.com";
        };
    };
}
