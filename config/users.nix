{ pkgs, ... }:

{
    users.mutableUsers = false;

    users.extraUsers.matthew = {
        description = "Matthew";
        passwordFile = "/nix/persist/pwd/matthew";
        createHome = true;
        isNormalUser = true;
        home = "/home/matthew";
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "libvirtd" ];
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB matthew"
        ];
    };
}
