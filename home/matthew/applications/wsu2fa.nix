{ pkgs, ... }:

let 
    wsu2fa = pkgs.writeShellScriptBin "wsu2fa" ''
          secret_key=REMOVED
          ${pkgs.oathToolkit}/bin/oathtool --totp -b "$secret_key"
    '';
in

{
    home.packages = [ wsu2fa ];
}
