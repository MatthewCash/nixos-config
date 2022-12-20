{ stableLib, inputs, homeConfigPath }:

let
    homeNames = builtins.attrNames (stableLib.attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir homeConfigPath));
    homeList = builtins.map (homeName: {
        name = homeName;
        value = {
            imports = [
                inputs.impermanence.nixosModules.home-manager.impermanence
                inputs.tpm-fido.nixosModules.home-manager.default
            ] ++ import "${homeConfigPath}/${homeName}" { inherit homeName; };

            home.persistence."/mnt/home/${homeName}".allowOther = true;
            systemd.user.startServices = "sd-switch";
            home.stateVersion = "22.11";
        };
    }) homeNames;

    homeConfigs = builtins.listToAttrs homeList;
in

homeConfigs
