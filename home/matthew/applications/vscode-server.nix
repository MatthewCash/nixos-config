{ pkgs, inputs, ... }:

{
    imports = [
        inputs.nixos-vscode-server.nixosModules.home-manager.nixos-vscode-server
    ];

    services.vscode-server = {
        enable = true;
        useFhsNodeEnvironment = true;
        extensions = with pkgs.vscode-extensions; [ 
            ms-vscode.cpptools 
            jnoortheen.nix-ide 
            github.copilot
            dbaeumer.vscode-eslint
            github.vscode-pull-request-github
            eamodio.gitlens
        ];
    };
}
