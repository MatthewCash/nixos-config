{ pkgsStable, pkgsUnstable, persistenceHomePath, name, ... }:

let
    vscode = pkgsUnstable.vscode.overrideAttrs(oldAttrs: {
         desktopItem = pkgsStable.makeDesktopItem {
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

    vscode-fhs = pkgsStable.buildFHSUserEnvBubblewrap {
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
        extensions = with pkgsUnstable.vscode-extensions; [
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
