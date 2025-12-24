{
    "chrome://messenger/content/messenger.xhtml" = {
        task-tree-filtergroup.value = "throughcurrent";

        unifinder-search-results-tree-col-title.ordinal = 1;
        unifinder-search-results-tree-col-startdate.ordinal = 3;
        unifinder-search-results-tree-col-enddate.ordinal = 5;
        unifinder-search-results-tree-col-categories.ordinal = 7;
        unifinder-search-results-tree-col-location.ordinal = 9;
        unifinder-search-results-tree-col-status.ordinal = 11;
        unifinder-search-results-tree-col-calendarname.ordinal = 13;

        messengerWindow = {
            screenX = 0;
            screenY = 0;
            sizemode = "maximized";
        };

        today-pane-splitter.hidden = "";
        today-none-box.collapsed = "";
        today-minimonth-box.collapsed = "";
        todo-tab-panel.collapsed = "";

        agenda-panel = {
            collapsed = "-moz-missing\n";
            collapsedinmodes = "calendar";
        };

        mini-day-box.collapsed = "-moz-missing\n";

        folderTree.mode = "all";

        quickFilterBar.visible = false;

        messagepaneboxwrapper = {
            collapsed = false;
            width = 1400;
        };

        spacesToolbar.hidden = true;

        calendar-task-tree = {
            widths = "13 14 14 14 14 14 14 14 14 14 14 14";
            ordinals = "1 3 5 7 9 11 13 15 17 19 21 23";
        };

        unifinder-todo-tree = {
            widths = "13 13 13 13 13 13 13 13 13 13 13 13";
            ordinals = "1 1 1 1 1 1 1 1 1 1 1 1";
        };

        today-pane-panel.collapsedinmodes = "mail";

        folderPaneHeaderBar.hidden = true;

        toolbar-menubar.autohide = "";

        status-bar.hidden = "";

        menu_showTaskbar.checked = false;

        unifiedToolbar.state = builtins.toJSON {
            mail = [
                "write-message"
                "get-messages"
                "junk"
                "reply"
                "reply-all"
                "mark-as"
                "search-bar"
            ];
        };

        threadPaneHeader.hidden = true;
    };

    "chrome://messenger/content/FilterListDialog.xhtml" = {
        filterListDialog = {
            screenX = 0;
            screenY = 0;
            width = 800;
            height = 500;
        };
    };

    "chrome://messenger/content/messengercompose/messengercompose.xhtml" = {
        msgcomposeWindow = {
            screenX = 0;
            screenY = 0;
            width = 860;
            height = 800;
            sizemode = "normal";
        };
    };
}

