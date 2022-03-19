{ pkgs, ... }:

{
    programs.java = {
        enable = true;
        package = pkgs.adoptopenjdk-jre-hotspot-bin-16;
    };
}