{ lib, pkgsUnstable, persistenceHomePath, accentColor, ... }:

{
    programs.opencode = {
        enable = true;

        settings = {
            autoupdate = false;
            model = "openai/gpt-5.5";

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

            permission."playwright_*" = "ask";
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

  home.persistence."${persistenceHomePath}".files = [
    ".local/share/opencode/auth.json"
  ];
}
