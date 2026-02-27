{ pkgsUnstable, persistenceHomePath, ... }:

let
    steam = pkgsUnstable.steam.override {
        extraPkgs = pkgs: with pkgs; [ kdePackages.breeze ];
    };
in

{
    home.persistence."${persistenceHomePath}".directories = [
        ".local/share/Steam"
        ".local/share/vulkan"
        ".config/unity3d"
        ".cache/mesa_shader_cache"

        # Steam Games
        ".local/share/Colossal Order"
    ];

    home.packages = [ steam ];
}
