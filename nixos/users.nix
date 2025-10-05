{ pkgsUnstable, stableLib, persistPath, homeMountPath, users, ... }:

let
    createDisplayName = name: stableLib.strings.toUpper (builtins.substring 0 1 name) +
        builtins.substring 1 (builtins.stringLength name) name;

    buildUserConfig = name: config: {
        inherit name;
        description = config.displayName or createDisplayName name;
        hashedPasswordFile = "${persistPath}/pwd/${name}";
        isNormalUser = true;
        home = "/home/${name}";
        shell = config.shell or pkgsUnstable.zsh;
        extraGroups = [ "wheel" ] ++ config.groups or [];
        openssh.authorizedKeys.keys = config.authorizedKeys or [];
        pamMount = stableLib.mkIf (config ? usePamMount && config.usePamMount) {
            path = "/dev/main/crypt-home-${name}";
            mountpoint = "${homeMountPath}/${name}";
            fstype = "crypt";
        };
    };
in

{
    environment.persistence.${persistPath}.directories = [ "/var/lib/nixos" ];

    users = {
        users = builtins.mapAttrs buildUserConfig users;
        mutableUsers = false;
    };
}
