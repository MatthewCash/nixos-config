{ pkgsUnstable, persistenceHomePath, ... }:

{
    home.persistence."${persistenceHomePath}".directories = [
        ".local/share/Steam"
        ".local/share/vulkan"
        ".config/unity3d"
        ".cache/mesa_shader_cache"

        # Steam Games
        ".local/share/Colossal Order"
    ];

    home.packages = with pkgsUnstable; [ steam ];
}
