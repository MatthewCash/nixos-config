{ accentColor }:

{
    # A reference avoids the shipped schema's overlapping "none"
    # and color-reference alternatives while retaining transparency.
    defs.terminal = "none";
    theme = {
        primary = accentColor.hex;
        secondary = accentColor.hex;
        accent = accentColor.hex;
        error = "#ef4444";
        warning = "#f59e0b";
        success = "#22c55e";
        info = accentColor.hex;
        text = "#e6e6e6";
        textMuted = "#888888";
        background = "terminal";
        backgroundPanel = "terminal";
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
        diffContextBg = "terminal";
        diffLineNumber = "#666666";
        diffAddedLineNumberBg = "#1a2e1a";
        diffRemovedLineNumberBg = "#2e1a1a";
        markdownText = "#e6e6e6";
        markdownHeading = accentColor.hex;
        markdownLink = accentColor.hex;
        markdownLinkText = accentColor.hex;
        markdownCode = "#cccccc";
        # OpenCode 2's V1 theme converter requires this token.
        markdownCodeBlock = "#cccccc";
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
        syntaxOperator = "#e6e6e6";
        syntaxPunctuation = "#888888";
    };
}
