{ lib, pkgsUnstable, persistenceHomePath, accentColor, ... }:

{
    programs.opencode = {
        enable = true;
        themes.main = import ./theme.nix { inherit accentColor; };
        extraPackages = [ pkgsUnstable.libnotify ];
        validateFiles = {
            config = true;
            cli = true;
        };

        context = ''
            Do not use playwright unless DOM access is truly necessary and the user intends it.
            Use `nix shell` to use packages that are not in PATH.
            / (and /tmp) may be on a small tmpfs, if so, use /mnt/persist/tmp for large temp.
            Do not attempt to use sudo.
            Do not attempt to `nixos-rebuild switch`.
            Do not ask for broad directory access like /, ~, or ~/.config.
            If root is ABSOLUTELY necessary, you can use run0, but ONLY with simple commands and SHORT inline scripts, not arbitrary files.
            Do not search (grep) large directories like /nix/store.
            If asked to commit, do not add a coauthor or sign the commit, it may break the harness.
        '';

        settings = {
            autoupdate = false;
            snapshot = false;
            model = "openai/gpt-6.1-sol";

            lsp = {
                clangd = {
                    command = [ (lib.getExe' pkgsUnstable.clang-tools "clangd") ];
                    extensions = [ ".c" ".cpp" ".cc" ".cxx" ".c++" ".h" ".hpp" ".hh" ".hxx" ".h++" ];
                };

                docker-langserver = {
                    command = [ (lib.getExe pkgsUnstable.dockerfile-language-server) ];
                    extensions = [ "Dockerfile" ".dockerfile" ];
                };

                gopls = {
                    command = [ (lib.getExe pkgsUnstable.gopls) ];
                    extensions = [ ".go" ];
                };

                marksman = {
                    command = [ (lib.getExe pkgsUnstable.marksman) ];
                    extensions = [ ".md" ".markdown" ];
                };

                nil = {
                    command = [ (lib.getExe pkgsUnstable.nil) ];
                    extensions = [ ".nix" ];
                };

                pyright = {
                    command = [ (lib.getExe' pkgsUnstable.basedpyright "basedpyright-langserver") "--stdio" ];
                    extensions = [ ".py" ".pyi" ];
                };

                rust = {
                    command = [ (lib.getExe pkgsUnstable.rust-analyzer) ];
                    extensions = [ ".rs" ];
                };

                typescript = {
                    command = [ (lib.getExe pkgsUnstable.typescript-language-server) "--stdio" ];
                    extensions = [ ".ts" ".tsx" ".js" ".jsx" ".mjs" ".cjs" ".mts" ".cts" ];
                };

                vscode-css-language-server = {
                    command = [ (lib.getExe' pkgsUnstable.vscode-langservers-extracted "vscode-css-language-server") "--stdio" ];
                    extensions = [ ".css" ];
                };

                vscode-html-language-server = {
                    command = [ (lib.getExe' pkgsUnstable.vscode-langservers-extracted "vscode-html-language-server") "--stdio" ];
                    extensions = [ ".html" ];
                };

                vscode-json-language-server = {
                    command = [ (lib.getExe' pkgsUnstable.vscode-langservers-extracted "vscode-json-language-server") "--stdio" ];
                    extensions = [ ".json" ".jsonc" ];
                };

                vue = {
                    command = [ (lib.getExe pkgsUnstable.vue-language-server) "--stdio" ];
                    extensions = [ ".vue" ];
                };

                yaml-ls = {
                    command = [ (lib.getExe pkgsUnstable.yaml-language-server) "--stdio" ];
                    extensions = [ ".yaml" ".yml" ];
                };
            };

            mcp = {
                playwright = {
                    type = "local";
                    command = [
                        (lib.getExe pkgsUnstable.playwright-mcp)
                        "--browser"
                        "firefox"
                        "--isolated"
                    ];
                    enabled = true;
                };

                nixos = {
                    type = "local";
                    command = [ (lib.getExe pkgsUnstable.mcp-nixos) ];
                    enabled = true;
                };

                context7 = {
                    type = "local";
                    command = [ (lib.getExe pkgsUnstable.context7-mcp) ];
                    enabled = true;
                };
            };

            permission = {
                playwright_browser_navigate = "ask";
                external_directory = {
                    "/nix/**" = "allow";
                };
            };
        };

        cli = {
            theme.name = "main";
            scroll.speed = 1;
            attention = {
                notifications = true;
                sound = false;
            };
            plugins = [
                "-opencode.notifications"
                "./cli-plugins/desktop-notifications"
                "./cli-plugins/openai-usage"
                "-opencode.sidebar.context"
            ];
        };
    };

    xdg.configFile = {
        "opencode/cli-plugins/desktop-notifications/tui.ts".source = ./desktop-notifications.ts;
        "opencode/cli-plugins/openai-usage/tui.tsx".source = ./openai-usage.tsx;
    };

    home.persistence."${persistenceHomePath}" = {
        directories = [
            ".cache/opencode"
        ];

        files = [
            ".local/share/opencode/auth.json"
            ".local/share/opencode/opencode.db"
        ];
    };
}
