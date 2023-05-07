{ pkgsUnstable, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".local/share/Steam"
        ".local/share/vulkan"
        ".config/unity3d"
        ".cache/mesa_shader_cache"

        # Steam Games
        ".local/share/Colossal Order"
    ];

    home.packages = with pkgsUnstable; [ steam ];
}
