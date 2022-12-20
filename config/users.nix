{ pkgsUnstable, stableLib, pamMountUsers, ... }:

let
    createDisplayName = name: stableLib.strings.toUpper (builtins.substring 0 1 name) +
        builtins.substring 1 (builtins.stringLength name) name;

    buildUserConfig = name: {
        inherit name;
        description = createDisplayName name;
        passwordFile = "/nix/persist/pwd/${name}";
        createHome = true;
        isNormalUser = true;
        home = "/home/${name}";
        shell = pkgsUnstable.zsh;
        extraGroups = [ "wheel" "tss" "uhid" ];
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1cahhYmVTV0ewIug2zzGdeXruxWeJToxHDXbEBLoCB ${name}"
        ];
    } // stableLib.attrsets.optionalAttrs (builtins.elem name pamMountUsers)  {
        pamMount = {
            path = "/dev/main/crypt-home-${name}";
            mountpoint = "/mnt/storage/${name}";
            fstype = "crypt";
        };
    };
in

{
    users.mutableUsers = false;
    users.extraUsers.matthew = buildUserConfig "matthew";
}
