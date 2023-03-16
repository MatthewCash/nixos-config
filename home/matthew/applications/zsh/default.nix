{ pkgsStable, pkgsUnstable, persistenceHomePath, name, inputs, ... }:

{
    home.packages = with pkgsStable; [ wl-clipboard ];

    home.persistence."${persistenceHomePath}/${name}".files = [
        ".zsh_history"
    ];

    home.sessionVariables.COLORTERM = "truecolor";

    programs.zsh = {
        enable = true;

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
        enableSyntaxHighlighting = true;

        enableAutosuggestions = true;
        history.share = false;

        shellAliases = {
            watch = "watch -n 1";
            c = "wl-copy";
            p = "wl-paste";
            e = "$EDITOR";
            cd = "pushd > /dev/null";
        };

        initExtra = /* zsh */ ''
            ${builtins.readFile ./p10k.zsh}
            ${builtins.readFile ./git_formatter.sh}
            source /run/current-system/etc/profile

            unsetopt HIST_SAVE_BY_COPY

            bindkey "^[[3~" delete-char

            bindkey "^H" backward-kill-word
            bindkey "^[[3;5~" kill-word

            bindkey "^[[1;5C" forward-word
            bindkey "^[[1;5D" backward-word

            # Home / End
            bindkey "^[[H" beginning-of-line
            bindkey "^[[F" end-of-line

            typeset -g WORDCHARS="''${WORDCHARS/\//}"

            x() { command xdg-open "$@" 2>/dev/null }
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
