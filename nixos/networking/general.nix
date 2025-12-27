{ hostname, ... }:

{
    networking.hostName = hostname;

    boot.kernel.sysctl = {
        "net.ipv4.tcp_low_latency" = 1;
        "net.ipv4.tcp_delack_min" = 0;
        "net.ipv4.tcp_fastopen" = 3;
    };
}
