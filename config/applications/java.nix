{ pkgsUnstable, ... }:

{
    programs.java = {
        enable = true;
        package = pkgsUnstable.jdk17_headless;
    };
}
