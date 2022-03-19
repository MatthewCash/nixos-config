{ persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/chromium"
        ".cache/chromium"
    ];

    programs.chromium.enable = true;
}
