{ ... }:

{
    # Enable ephemeral SSH server on boot
    boot.initrd.network.ssh.enable = true;

    services.openssh = {
        enable = true;
        permitRootLogin = "no";
        extraConfig = ''
            PrintLastLog no
            TCPKeepAlive yes
            ClientAliveInterval 36000
        '';
    };

    programs.mosh.enable = true;
}
