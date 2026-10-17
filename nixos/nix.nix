{ nixpkgsStable, nixpkgsUnstable, ... }:

let
    shared = import ./nix-shared.nix;
in
{
    nix = {
        inherit (shared) gc;
        settings = shared.settings // { trusted-users = [ "@wheel" ]; };

        nixPath = [ "nixpkgs=${nixpkgsUnstable}" ];

        daemonCPUSchedPolicy = "idle";
        daemonIOSchedClass = "idle";
        daemonIOSchedPriority = 7;
    };

    environment.variables = {
        inherit nixpkgsStable nixpkgsUnstable;
        nixpkgs = nixpkgsUnstable;
    };
}
