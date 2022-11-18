{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [ texlive.combined.scheme-basic setzer ];
}
