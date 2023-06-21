{ pkgsStable, ... }:

{
    networking.networkmanager.enable = true;

    systemd.services.wpa_supplicant.environment.OPENSSL_CONF = pkgsStable.writeText "openssl.cnf" /* ini */ ''
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
