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
            ClientAliveInterval 30
        '';
    };

    programs.mosh.enable = true;
}
