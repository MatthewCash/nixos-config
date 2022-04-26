{ pkgs, ... }:

{
    users.mutableUsers = false;

    users.extraUsers.matthew = {
        description = "Matthew";
    	hashedPassword = "$6$EjrPLKMWVyP8NeF6$7IH.rKSAL41g/QAsBCjPhdmTPMK2shb1Do6gRHqquJTE6sPKeoR/pJFlXxCDQoXD0fRqZjIpA/8DMJG69wJSo.";
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
