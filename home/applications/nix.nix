{ ... }:

{
    nix = {
        enable = true;
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            use-xdg-base-directories = true;
        };
    };
}
