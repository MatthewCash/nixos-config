# From https://github.com/nix-community/home-manager/blob/master/modules/misc/dconf.nix
{ pkgs, lib, inputs, ... }:

let
    inherit (inputs.home-manager.lib.hm) gvariant;
    toDconfIni = lib.generators.toINI {
        mkKeyValue = key: value: "${key}=${toString (gvariant.mkValue value)}";
    };
    generateDconfDb = settings: let
        iniFile = pkgs.writeText "dconf.ini" (toDconfIni settings);
    in pkgs.runCommand "user" { } /* bash */ ''
        mkdir key_files
        ln -s ${iniFile} key_files/
        ${lib.getExe pkgs.dconf} compile $out key_files
    '';
in

{
    inherit generateDconfDb;
}
