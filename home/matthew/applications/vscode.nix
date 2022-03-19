{ pkgs, persistenceHomePath, name, ... }:

let
    vscode = pkgs.vscode.overrideAttrs(oldAttrs: {
         desktopItem = pkgs.makeDesktopItem {
            name = "code";
            icon = "vscode";
            desktopName = "Visual Studio Code";
            comment = "Code Editing. Redefined.";
            genericName = "Text Editor";
            exec = "code";
            startupNotify = true;
            categories = [ "Utility" "TextEditor" "Development" "IDE" ];
            mimeTypes = [ "text/plain" "inode/directory" ];
        };
    });

    vscode-fhs = pkgs.buildFHSUserEnvBubblewrap {
        name = "code";

        targetPkgs = pkgs: (with pkgs; [
            glibc
            curl
            icu
            libunwind
            libuuid
            openssl
            zlib
            krb5
         ]);

        extraInstallCommands = ''
           ln -s "${vscode}/share" "$out/"
        '';

        runScript = "${vscode}/bin/code";

        dieWithParent = false;

        meta = {
            description = ''
                Wrapped variant of vs-code which launches in a FHS compatible envrionment.
                Should allow for easy usage of extensions without nix-specific modifications.
            '';
        };
    };
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/Code"
    ];

    programs.vscode = {
        enable = true;
        package = vscode;
        extensions = with pkgs.vscode-extensions; [
            ms-vscode.cpptools
            jnoortheen.nix-ide
            github.copilot
            dbaeumer.vscode-eslint
            github.vscode-pull-request-github
            eamodio.gitlens
            esbenp.prettier-vscode
            octref.vetur
        ];
    };
}
