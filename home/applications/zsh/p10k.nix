{ accentColor }:

/* zsh */ ''
    typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=234
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( status context dir vcs )
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        command_execution_time background_jobs direnv virtualenv anaconda pyenv goenv nodenv nvm nodeenv
        rbenv rvm fvm luaenv jenv plenv phpenv scalaenv haskell_stack midnight_commander nix_shell
    )
    typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR="\uE0BC"
    typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL="\ue0b6"
    typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL="\ue0b4"
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL="\ue0b6"
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL="\ue0b4"
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
    typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
    typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
    typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=250
    local anchor_files=(
        .bzr .citc .git .hg .node-version .python-version .go-version .ruby-version .lua-version .java-version
        .perl-version .php-version .tool-version .shorten_folder_marker .svn .terraform CVS Cargo.toml
        composer.json go.mod package.json stack.yaml
    )
    typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(''${(j:|:)anchor_files})"
    typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
    typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
    typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
    typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
    typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
    typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
    typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
    typeset -g POWERLEVEL9K_DIR_CLASSES=()
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON="?"
    typeset -g POWERLEVEL9K_DIR_BACKGROUND="${accentColor.hex}"
    typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=227
    typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=196
    typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=8
    typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
    typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
    typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION=${"'"}''${''$((my_git_formatter()))+''${my_git_format}}'
    typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
    typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
    typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
    typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=false
    typeset -g POWERLEVEL9K_STATUS_OK=false
    typeset -g POWERLEVEL9K_STATUS_ERROR=true
    typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION=""
    typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=15
    typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=9
    typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
    typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
    typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=3
    typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=1
    typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=255
    typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=255
    typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=255
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=41
    typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
    typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
''
