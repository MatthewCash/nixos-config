{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable.gnome; [ gnome-terminal ];

    dconf.settings = {
        "org/gnome/terminal/legacy" = {
            menu-accelerator-enabled = false;
            new-terminal-mode = "tab";
        };
    };

    programs.gnome-terminal = {
        enable = true;
        profile."b1dcc9dd-5262-4d8d-a863-c897e6d979ba" = {
            visibleName = "Main";
            cursorShape = "ibeam";
            showScrollbar = false;
            default = true;
            colors = {
                backgroundColor = "black";
                foregroundColor = "white";
                palette = [ "rgb(23,20,33)" "rgb(192,28,40)" "rgb(38,162,105)" "rgb(162,115,76)" "rgb(18,72,139)" "rgb(163,71,186)" "rgb(42,161,179)" "rgb(208,207,204)" "rgb(94,92,100)" "rgb(246,97,81)" "rgb(51,209,122)" "rgb(233,173,12)" "rgb(42,123,222)" "rgb(192,97,203)" "rgb(51,199,222)" "rgb(255,255,255)" ];
            };
        };
    };
}
