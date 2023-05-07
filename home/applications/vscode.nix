{ pkgsStable, pkgsUnstable, persistenceHomePath, name, inputs, system, ... }:

let
    vscodium = (pkgsUnstable.vscodium.overrideAttrs (oldAttrs: {
         desktopItem = pkgsStable.makeDesktopItem {
            name = "codium";
            exec = "codium %F";
            icon = "vscode";
            startupWMClass = "VSCodium";
            desktopName = "Visual Studio Codium";
            comment = "Code Editing. Redefined.";
            genericName = "Text Editor";
            startupNotify = true;
            categories = [ "Utility" "TextEditor" "Development" "IDE" ];
            mimeTypes = [ "text/plain" "inode/directory" ];
        };
    })).override {
        commandLineArgs = "--touch-events";
    };

    vscodium-fhs = pkgsStable.buildFHSUserEnvBubblewrap {
        name = "codium";

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
           ln -s "${vscodium}/share" "$out/"
        '';

        runScript = "${vscodium}/bin/codium";

        dieWithParent = false;

        meta = {
            description = ''
                Wrapped variant of VSCodium which launches in a FHS compatible envrionment.
                Should allow for easy usage of extensions without nix-specific modifications.
            '';
        };
    };
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".config/VSCodium"
    ];

    programs.vscode = {
        enable = true;
        package = vscodium;
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgsUnstable.vscode-extensions; [
            jnoortheen.nix-ide
            dbaeumer.vscode-eslint
            github.vscode-pull-request-github
            eamodio.gitlens
            esbenp.prettier-vscode
            octref.vetur
            inputs.codium-theme.defaultPackage.${system}
        ];
        userSettings = {
            "workbench.colorTheme" = "Main Theme";
            "window.titleBarStyle" = "custom";
            "editor.smoothScrolling" = true;
            "editor.cursorSmoothCaretAnimation" = true;
            "workbench.list.smoothScrolling" = true;
            "terminal.integrated.smoothScrolling" = true;
            "editor.renderWhitespace" = "all";
            "files.trimTrailingWhitespace" = true;
            "files.insertFinalNewline" = true;
            "files.trimFinalNewlines" = true;
            "editor.wordWrap" = "on";
            "window.commandCenter" = true;
            "editor.fontFamily" = "'CaskaydiaCove Nerd Font Regular', monospace";
        };
    };
}
