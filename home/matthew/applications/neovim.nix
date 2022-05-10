{ pkgs, ... }:

{
    home.sessionVariables = rec {
        EDITOR = "${pkgs.neovim}/bin/nvim";
        VISUAL = EDITOR;
    };

    programs.neovim = {
        enable = true;
        
        coc.enable = true;

        coc.settings = {
            suggest = {
                noselect = false;
                enablePreview = true;
                removeDuplicateItems = true;
            };

            languageserver = {
                ccls = {
                    command = "ccls";
                    filetypes = [ "c" "cpp" "cc" "ino" ];
                    rootPatterns = [ ".ccls" "compile_commands.json" ".vim/" ".git/" ".hg/" ];
                    initializationOptions.cache.directory = "/tmp/ccls";
                };
            };
        };

        extraConfig = ''
            " Colemak-DH remapping
            noremap  a a
            noremap  z z
            noremap  d c 
            noremap  s d
            noremap  f f
            noremap  t f
            noremap  g g
            noremap  m h
            noremap  u i
            noremap  n j
            noremap  e k
            noremap  i l
            noremap  h m
            noremap  k n
            noremap  y o
            noremap  ; p
            noremap  q q
            noremap  p r
            noremap  r s
            noremap  b t
            noremap  l u
            noremap  v v
            noremap  w w
            noremap  c x
            noremap  j y
            noremap  x z

            let g:nix_recommended_style=0

            inoremap <C-H> <C-W>	
            tnoremap <Esc> <C-\><C-n>
            set mouse=a
            set number
            set relativenumber
            set hidden
            set cursorline
            set expandtab
            set autoindent
            set smartindent
            set shiftwidth=4
            set tabstop=4
            set softtabstop=4
            set encoding=utf8
            set history=5000
            set clipboard=unnamedplus
          
            augroup RestoreCursorShapeOnExit
            autocmd!
            autocmd VimLeave * set guicursor=a:ver25
            augroup END

            let g:airline_powerline_fonts = 1
            let g:airline#extensions#tabline#enabled = 1

            " Git Gutter
            set updatetime=250
            let g:gitgutter_max_signs = 500
            " No mapping
            let g:gitgutter_map_keys = 0

            " Colors
            let g:gitgutter_override_sign_column_highlight = 0
            highlight clear SignColumn
            highlight GitGutterAdd ctermfg=2
            highlight GitGutterChange ctermfg=3
            highlight GitGutterDelete ctermfg=1
            highlight GitGutterChangeDelete ctermfg=4

            set noshowmode  " to get rid of thing like --INSERT--
            set noshowcmd  " to get rid of display of last command
            set shortmess+=F  " to get rid of the file name displayed in the command line bar

            " Current line number color
            highlight CursorLineNr term=bold cterm=NONE ctermfg=lightmagenta ctermbg=NONE gui=NONE guifg=lightmagenta guibg=NONE


            highlight clear SignColumn

            highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
            command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
        '';

        viAlias = true;
        withNodeJs = true;
        withPython3 = true;

        extraPackages = with pkgs; [
            ccls
            clang-tools
        ];

        plugins = with pkgs.vimPlugins; [
            ale
            gruvbox-nvim
            nerdtree
            vim-nix
            emmet-vim
            vim-gitgutter
            vim-airline
            vim-airline-themes
            coc-nvim
            coc-snippets
            coc-highlight
            vim-polyglot
            copilot-vim
            indentLine
            yats-vim          
            vim-markdown
            neoformat
        ];
    };
}
