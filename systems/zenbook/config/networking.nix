{ ... }:

{
    networking.networkmanager = {
        enable = true;
        insertNameservers = [ "192.168.1.201" "1.1.1.1" ];
    };

    networking.hosts = {
        "172.30.0.2" = [ "epsilon.zero" ];
        "172.30.0.5" = [ "omicron.zero" ];
    };

    environment.persistence."/nix/persist".directories = [
        "/etc/NetworkManager/system-connections"
    ];
}
