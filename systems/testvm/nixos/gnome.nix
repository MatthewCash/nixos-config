{ stableLib, config, ... }:

{
    users.users = stableLib.attrsets.mapAttrs (n: v: { extraGroups = [ "video" ]; })
        config.home-manager.users;
}
