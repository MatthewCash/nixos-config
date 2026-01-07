{ ... }:

{
    services.system76-scheduler = {
        enable = true;
    };

    services.scx = {
        enable = true;
        scheduler = "scx_lavd";
    };
}
