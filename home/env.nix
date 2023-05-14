{ pkgsUnstable, ... }:

{
    home.sessionVariables = rec {
        EDITOR = "${pkgsUnstable.helix}/bin/hx";
        VISUAL = EDITOR;
    };
}
