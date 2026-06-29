{ ... }:

{
    hardware.amdgpu = {
        initrd.enable = true;
        overdrive.enable = true;
    };

    services.lact = {
        enable = true;
        settings = {
            version = 5;

            daemon = {
                log_level = "info";
                admin_group = "wheel";
            };

            # this gpu crashes under heavy load :/
            gpus."1002:744C-1849:5304-0000:03:00.0".max_core_clock = 1700;
        };
    };
}
