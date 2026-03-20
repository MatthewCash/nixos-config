{ stableLib, persistPath, ... }:

{
    age.identityPaths = [
        "${persistPath}/etc/ssh/ssh_host_ed25519_key"
    ];

    environment.persistence.${persistPath}.files = [
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
    ];

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
