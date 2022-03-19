{ ... }:

{
    programs.htop = {
        enable = true;
        settings = {
            show_program_path = false;
            show_cpu_frequency = true;
            show_cpu_temperature = true;
        };
    };
}
