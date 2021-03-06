{ pkgs, persistenceHomePath, name, inputs, ... }:

{
    home.packages = with pkgs; [ wl-clipboard ];

    home.persistence."${persistenceHomePath}/${name}".files = [
        ".zsh_history"
    ];

    home.sessionVariables.COLORTERM = "truecolor";

    programs.zsh = {
        enable = true;

        oh-my-zsh = {
            enable = true;
            plugins = [ "git" "bundler" "dotenv" "rake" "npm" ];
        };

        plugins = [
            {
                name = "zsh-nix-shell";
                file = "nix-shell.plugin.zsh";
                src = inputs.zsh-nix-shell;
            }
            {
                name = "agnoster";
                file = "agnoster.zsh-theme";
                src = inputs.agnoster-zsh-theme;
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
        };

        initExtra = ''
            unsetopt HIST_SAVE_BY_COPY

            bindkey '^H' backward-kill-word
            bindkey '5~' kill-word

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
                    ${pkgs.inotify-tools}/bin/inotifywait $1 > /dev/null 2>&1
                    ''${@:2}
                done
            }
        '';
    };
}
