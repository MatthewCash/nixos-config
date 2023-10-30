{ pkgsStable, pkgsUnstable, stableLib, useImpermanence, persistenceHomePath, name, inputs, accentColor, config, ... }:

{
    home.packages = with pkgsStable; [ wl-clipboard ];

    home.persistence."${persistenceHomePath}/${name}".files = stableLib.mkIf useImpermanence [
        ".cache/zsh/history"
    ];

    home.sessionVariables.COLORTERM = "truecolor";

    programs.zsh = {
        enable = true;

        dotDir = ".config/zsh";
        history.path = "${config.xdg.cacheHome}/zsh/history";

        enableVteIntegration = true;

        oh-my-zsh.enable = true;

        plugins = [
            {
                name = "zsh-nix-shell";
                file = "nix-shell.plugin.zsh";
                src = inputs.zsh-nix-shell;
            }
            {
                name = "powerlevel10k";
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                src = pkgsUnstable.zsh-powerlevel10k;
            }
        ];

        enableCompletion = true;
        syntaxHighlighting.enable = true;
        enableAutosuggestions = true;

        history.share = false;

        shellAliases = {
            watch = "watch -n 1";
            c = "wl-copy";
            p = "wl-paste";
            e = "$EDITOR";
        };

        initExtra = /* zsh */ ''
            ${builtins.readFile ./git_formatter.sh}
            ${import ./p10k.nix { inherit accentColor; } }

            file="/run/current-system/etc/profile" && test -f $file && source $file

            unsetopt HIST_SAVE_BY_COPY

            bindkey "^[[3~" delete-char

            # bindkey "\C-h" backward-kill-word
            bindkey "^[[3;5~" kill-word

            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word

            # Home / End
            bindkey "^[[H" beginning-of-line
            bindkey "^[[F" end-of-line

            typeset -g WORDCHARS="''${WORDCHARS/\//}"

            cd() { pushd "''${1:-$HOME}" > /dev/null }
            x() {
                command xdg-open "$@" 2>/dev/null
                if [[ $? -eq 2 ]]; then
                    >&2 echo "File $1 not found!"
                fi
            }
            wf() {
                if [[ ! -f "$1" ]]; then
                    >&2 echo "File $1 not found!"
                    return 1
                fi

                if [[ -z "$2" ]]; then
                    >&2 echo "No command provided!"
                    return 1
                fi

                while :; do
                    ${pkgsStable.inotify-tools}/bin/inotifywait $1 > /dev/null 2>&1
                    ''${@:2}
                done
            }
        '';
    };
}
