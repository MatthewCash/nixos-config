{ pkgs, ... }:

{
    networking.networkmanager = {
        enable = true;
        appendNameservers = [ "1.1.1.1" ];
    };

    networking.hosts = {
        "172.30.0.2" = [ "epsilon.zero" ];
        "172.30.0.5" = [ "omicron.zero" ];
    };

    environment.persistence."/nix/persist".directories = [
        "/etc/NetworkManager/system-connections"
    ];

    systemd.services.wpa_supplicant.environment.OPENSSL_CONF = pkgs.writeText "openssl.cnf" ''
        openssl_conf = openssl_init
        [openssl_init]
        ssl_conf = ssl_sect
        [ssl_sect]
        system_default = system_default_sect
        [system_default_sect]
        Options = UnsafeLegacyRenegotiation
        [system_default_sect]
        CipherString = Default:@SECLEVEL=0
   '';
}
