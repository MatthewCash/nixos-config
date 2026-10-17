{
    gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
    };

    settings = {
        experimental-features = [ "nix-command" "flakes" ];
        use-xdg-base-directories = true;
        auto-optimise-store = true;
    };
}
