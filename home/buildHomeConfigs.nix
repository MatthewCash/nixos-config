{ lib, inputs, homeConfigPath, ... }:

let
    homeNames = builtins.attrNames (lib.attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir homeConfigPath));
    homeList = builtins.map (homeName:
        {
            name = homeName;
            value = {
                imports = [
                    inputs.impermanence.nixosModules.home-manager.impermanence
                ] ++ import "${homeConfigPath}/${homeName}" { inherit homeName; };

                home.persistence."/nix/persist/home/${homeName}".allowOther = true;
                home.stateVersion = "22.05";
            };
        }) homeNames;
    homeConfigs = builtins.listToAttrs homeList;
in

homeConfigs
