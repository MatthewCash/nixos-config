{ ... }:

{
    virtualisation.podman = {
        enable = true;
        autoPrune ={
            enable = true;
            flags = [ "--all" ];
        };
        dockerSocket.enable = true;
        dockerCompat = true;
    };
}
