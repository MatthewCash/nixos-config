{
    "general.autoScroll" = true;
    "gfx.webrender.all" = true;
    "layers.acceleration.force-enabled" = true;
    "media.eme.enabled" = true;
    "media.ffmpeg.vaapi.enabled" = true;
    "media.ffvpx.enabled" = false;
    "media.navigator.mediadatadecoder_vpx_enabled" = true;
    "media.rdd-vpx.enabled" = false;
    "media.videocontrols.picture-in-picture.video-toggle.has-used" = true;
    "pdfjs.enabledCache.state" = true;
    "pdfjs.migrationVersion" = 2;
    "pref.downloads.disable_button.edit_actions" = false;
    "pref.general.disable_button.default_browser" = false;
    "print.more-settings.open" = true;
    "privacy.donottrackheader.enabled" = true;
    "reader.color_scheme" = "dark";
    "reader.content_width" = 5;
    "services.sync.declinedEngines" = "";
    "services.sync.engine.addresses.available" = true;
    "signon.rememberSignons" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = true;

    # Telemetry
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "devtools.onboarding.telemetry.logged" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.sessions.current.clean" = true;
    "toolkit.telemetry.server" = "";


    # No warning on fullscreen
    "full-screen-api.warning.timeouts" = false;

    # Remove alt-menu
    "ui.key.menuAccessKeyFocuses" = false;

    # Fix double click highlight includes trailing space
    "layout.word_select.eat_space_to_next_word" = true;

    # Open Popups in new tabs
    "browser.link.open_newwindow.restriction" = 0;

    # UI Customization
    "browser.toolbars.bookmarks.visibility" = "never";
    "browser.uiCustomization.state" = {
        "placements" = {
            "widget-overflow-fixed-list" = [
                "developer-button"
                "panic-button"
                "print-button"
                "screenshot-button"
            ];
            "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "urlbar-container"
                "downloads-button"
                "unified-extensions-button"
            ];
            "toolbar-menubar" = [ "menubar-items" ];
            "TabsToolbar" = [ "tabbrowser-tabs" "alltabs-button" ];
            "PersonalToolbar" = [ "import-button" "personal-bookmarks" ];
        };
        "dirtyAreaCache" = [
            "nav-bar"
            "PersonalToolbar"
            "toolbar-menubar"
            "TabsToolbar"
            "widget-overflow-fixed-list"
        ];
        "seen" = [
            "sponsorblocker_ajay_app-browser-action"
            "ublock0_raymondhill_net-browser-action"
        ];
        "currentVersion" = 23;
        "newElementCount" = 6;
    };
    "browser.urlbar.placeholderName" = "Google";
    "browser.urlbar.placeholderName.private" = "Google";
    "browser.urlbar.quicksuggest.migrationVersion" = 2;
    "browser.download.autohideButton" = true;

    # Theme
    "devtools.theme" = "dark";
    "extensions.activeThemeID" = "default-theme@mozilla.org";
    "browser.tabs.allow_transparent_browser" = true;

    # New Tab Page
    "browser.newtabpage.pinned" = [];
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

    # Backspace goes back
    "browser.backspace_action" = 0;

    # Hide single tab
    "gnomeTheme.hideSingleTab" = true;

    # No Refresh Banner
    "browser.slowStartup.notificationDisabled" = true;
    "browser.disableResetPrompt" = true;

    # Disable tab restore page
    "browser.sessionstore.max_resumed_crashes" = 0;

    # Hide Firefox View
    "browser.tabs.firefox-view" = false;

    # Allow unverified addons
    "xpinstall.signatures.required" = false;

    # Enable userChrome + userContent styling
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Allow chrome debugging
    "devtools.chrome.enabled" = true;
    "devtools.debugger.remote-enabled" = true;
    "devtools.debugger.prompt-connection" = false;

    # Allow addons to modify mozila URLs
    "extensions.webextensions.restrictedDomains" = "";

    # Ask where to save downloads
    "browser.download.useDownloadDir" = false;
}
