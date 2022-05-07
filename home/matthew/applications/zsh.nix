{ pkgs, persistenceHomePath, name, ... }:

{
    home.packages = with pkgs; [ wl-clipboard ];

    home.persistence."${persistenceHomePath}/${name}".files = [
        ".zsh_history"
    ];

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
                src = pkgs.fetchFromGitHub {
                    owner = "chisui";
                    repo = "zsh-nix-shell";
                    rev = "v0.5.0";
                    sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
                };
            }
            {
                name = "agnoster";
                file = "agnoster.zsh-theme";
                src = pkgs.fetchFromGitHub {
                    owner = "MatthewCash";
                    repo = "agnoster-zsh-theme";
                    rev = "6003192cb698ad63ca8f3dc61f029033d5b5d0a8";
                    sha256 = "sha256-0VmgFYofjh3YUSKu8tBG7bjCOyF096zbBpfF5EjN7iA=";
                };
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
            wf()
            {
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
