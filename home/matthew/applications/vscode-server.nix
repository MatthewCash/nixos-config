{ pkgs, inputs, ... }:

{
    imports = [
        inputs.nixos-vscode-server.nixosModules.home-manager.nixos-vscode-server
    ];

    services.vscode-server = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [ 
            ms-vscode.cpptools 
            jnoortheen.nix-ide 
            github.copilot
            dbaeumer.vscode-eslint
            github.vscode-pull-request-github
            eamodio.gitlens
            octref.vetur
            redhat.java
        ];
        settings = {
            "java.jdt.ls.java.home" = "${pkgs.jdk17_headless}/lib/openjdk";
        };
    };
}
