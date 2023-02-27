{ ... }:

let
    formattingOptions = {
        "NewLine" = "\n";
        "UseTabs" = false;
        "TabSize" = 4;
        "IndentationSize" = 4;
        "SpacingAfterMethodDeclarationName" = false;
        "SpaceWithinMethodDeclarationParenthesis" = false;
        "SpaceBetweenEmptyMethodDeclarationParentheses" = false;
        "SpaceAfterMethodCallName" = false;
        "SpaceWithinMethodCallParentheses" = false;
        "SpaceBetweenEmptyMethodCallParentheses" = false;
        "SpaceAfterControlFlowStatementKeyword" = true;
        "SpaceWithinExpressionParentheses" = false;
        "SpaceWithinCastParentheses" = false;
        "SpaceWithinOtherParentheses" = false;
        "SpaceAfterCast" = true;
        "SpacesIgnoreAroundVariableDeclaration" = false;
        "SpaceBeforeOpenSquareBracket" = false;
        "SpaceBetweenEmptySquareBrackets" = false;
        "SpaceWithinSquareBrackets" = false;
        "SpaceAfterColonInBaseTypeDeclaration" = true;
        "SpaceAfterComma" = true;
        "SpaceAfterDot" = false;
        "SpaceAfterSemicolonsInForStatement" = true;
        "SpaceBeforeColonInBaseTypeDeclaration" = true;
        "SpaceBeforeComma" = false;
        "SpaceBeforeDot" = false;
        "SpaceBeforeSemicolonsInForStatement" = false;
        "SpacingAroundBinaryOperator" = "single";
        "IndentBraces" = false;
        "IndentBlock" = true;
        "IndentSwitchSection" = true;
        "IndentSwitchCaseSection" = true;
        "LabelPositioning" = "oneLess";
        "WrappingPreserveSingleLine" = true;
        "WrappingKeepStatementsOnSingleLine" = true;
        "NewLinesForBracesInTypes" = false;
        "NewLinesForBracesInMethods" = false;
        "NewLinesForBracesInProperties" = false;
        "NewLinesForBracesInAccessors" = false;
        "NewLinesForBracesInAnonymousMethods" = false;
        "NewLinesForBracesInControlBlocks" = false;
        "NewLinesForBracesInAnonymousTypes" = false;
        "NewLinesForBracesInObjectCollectionArrayInitializers" = false;
        "NewLinesForBracesInLambdaExpressionBody" = false;
        "NewLineForElse" = false;
        "NewLineForCatch" = false;
        "NewLineForFinally" = false;
        "NewLineForMembersInObjectInit" = false;
        "NewLineForMembersInAnonymousTypes" = false;
        "NewLineForClausesInQuery" = false;
    };
in

{
    home.file.".omnisharp/omnisharp.json".text = builtins.toJSON {
        FormattingOptions = formattingOptions;
    };
}