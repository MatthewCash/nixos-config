{ stableLib, ... }:

{
    # Enable ephemeral SSH server on boot
    boot.initrd.network.ssh.enable = true;

    services.openssh = {
        enable = true;
        settings = {
            PermitRootLogin = stableLib.mkOverride 900 "no";
            PrintLastLog = "no";
            TCPKeepAlive = "yes";
            ClientAliveInterval = 30;
        };
    };

    programs.mosh.enable = true;
}
