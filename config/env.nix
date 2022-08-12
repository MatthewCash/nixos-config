{ lib, config, ... }:

{
#    environment.variables = builtins.removeAttrs config.environment.variables [ "EDITOR" ];
    environment.variables.EDITOR = lib.mkForce "$EDITOR";
}
