let
    mkColumn = visible: ordinal: { inherit visible ordinal; };
    columns = {
        selectCol = mkColumn false 1;
        threadCol = mkColumn true 5;
        flaggedCol = mkColumn true 7;
        attachmentCol = mkColumn false 9;
        subjectCol = mkColumn true 11;
        unreadButtonColHeader = mkColumn false 3;
        senderCol = mkColumn false 13;
        recipientCol = mkColumn false 15;
        correspondentCol = mkColumn true 17;
        junkStatusCol = mkColumn false 19;
        receivedCol = mkColumn false 21;
        dateCol = mkColumn true 23;
        statusCol = mkColumn false 25;
        sizeCol = mkColumn false 27;
        tagsCol = mkColumn false 29;
        accountCol = mkColumn false 31;
        priorityCol = mkColumn false 33;
        unreadCol = mkColumn false 35;
        totalCol = mkColumn false 37;
        locationCol = mkColumn true 39;
        idCol = mkColumn false 41;
        deleteCol = mkColumn false 43;
    };
in

{
    "general.autoScroll" = true;

    # Allow unverified addons
    "xpinstall.signatures.required" = false;

    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    "mail.tabs.drawInTitlebar" = true;

    "mailnews.emptyTrash.dontAskAgain" = true;
    "mailnews.display.html_as" = 3;
    "mailnews.start_page.enabled" = false;
    "mailnews.database.global.views.conversation.columns" = columns;
    "mailnews.database.global.views.global.columns" = columns;
}
