{ lib, pkgsUnstable, persistenceHomePath, accentColor, ... }:

{
    programs.opencode = {
        enable = true;

        settings = {
            autoupdate = false;
            model = "openai/gpt-5.5";

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

            mcp.playwright = {
                type = "local";
                command = [
                    (lib.getExe pkgsUnstable.playwright-mcp)
                    "--browser"
                    "firefox"
                    "--isolated"
                ];
                enabled = true;
            };

            mcp.nixos = {
                type = "local";
                command = [ (lib.getExe pkgsUnstable.mcp-nixos) ];
                enabled = true;
            };

            mcp.context7 = {
                type = "local";
                command = [ (lib.getExe pkgsUnstable.context7-mcp) ];
                enabled = true;
            };

            permission = {
                external_directory = {
                    "/nix/**" = "allow";
                };
            };
        };

        tui.theme = "main";

        themes.main.theme = {
            primary = accentColor.hex;
            secondary = accentColor.hex;
            accent = accentColor.hex;
            error = "#ef4444";
            warning = "#f59e0b";
            success = "#22c55e";
            info = accentColor.hex;
            text = "#e6e6e6";
            textMuted = "#888888";
            background = "none";
            backgroundPanel = "none";
            backgroundElement = "#3a3a3a";
            border = "#333333";
            borderActive = accentColor.hex;
            borderSubtle = "#222222";
            diffAdded = "#22c55e";
            diffRemoved = "#ef4444";
            diffContext = "#888888";
            diffHunkHeader = "#555555";
            diffHighlightAdded = "#22c55e";
            diffHighlightRemoved = "#ef4444";
            diffAddedBg = "#1a2e1a";
            diffRemovedBg = "#2e1a1a";
            diffContextBg = "none";
            diffLineNumber = "#666666";
            diffAddedLineNumberBg = "#1a2e1a";
            diffRemovedLineNumberBg = "#2e1a1a";
            markdownText = "#e6e6e6";
            markdownHeading = accentColor.hex;
            markdownLink = accentColor.hex;
            markdownLinkText = accentColor.hex;
            markdownCode = "#cccccc";
            markdownBlockQuote = "#888888";
            markdownEmph = "#e6e6e6";
            markdownStrong = "#ffffff";
            markdownHorizontalRule = "#444444";
            markdownListItem = accentColor.hex;
            markdownListEnumeration = accentColor.hex;
            markdownImage = "#e6e6e6";
            markdownImageText = "#888888";
            syntaxComment = "#666666";
            syntaxKeyword = accentColor.hex;
            syntaxFunction = accentColor.hex;
            syntaxVariable = "#e6e6e6";
            syntaxType = "#cccccc";
            syntaxNumber = "#cccccc";
            syntaxString = "#cccccc";
            syntaxRegexp = "#cccccc";
            syntaxOperator = "#e6e6e6";
            syntaxPunctuation = "#888888";
        };
    };

    home.persistence."${persistenceHomePath}" = {
        files = [
            ".local/share/opencode/auth.json"
            ".local/share/opencode/opencode-stable.db"
        ];
    };
}
