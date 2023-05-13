{ pkgsUnstable, stableLib, persistPath, homeMountPath, users, ... }:

let
    createDisplayName = name: stableLib.strings.toUpper (builtins.substring 0 1 name) +
        builtins.substring 1 (builtins.stringLength name) name;

    buildUserConfig = name: config: {
        inherit name;
        description = config.displayName or createDisplayName name;
        passwordFile = "${persistPath}/pwd/${name}";
        isNormalUser = true;
        home = "/home/${name}";
        shell = config.shell or pkgsUnstable.zsh;
        extraGroups = [ "wheel" "tss" "uhid" ] ++ config.groups or [];
        openssh.authorizedKeys.keys = config.authorizedKeys or [];
        pamMount = stableLib.mkIf (config ? usePamMount && config.usePamMount) {
            path = "/dev/main/crypt-home-${name}";
            mountpoint = "${homeMountPath}/${name}";
            fstype = "crypt";
        };
    };
in

{
    users.mutableUsers = false;
    users.extraUsers = builtins.mapAttrs buildUserConfig users;
}
