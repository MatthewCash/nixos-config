{ pkgsUnstable, persistenceHomePath, name, ... }:

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/chromium"
        ".cache/chromium"
    ];

    programs.chromium = {
        enable = true;
        package = pkgsUnstable.ungoogled-chromium;
        commandLineArgs = [
            "--enable-features=UseOzonePlatform"
            "--ozone-platform=wayland"
            "--ignore-gpu-blocklist"
        ];
        extensions = [
            {
                id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; # ublock origin
            }
        ];
    };
}
