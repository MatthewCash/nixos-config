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
    "network.dns.disablePrefetch" = true;
    "network.http.speculative-parallel-limit" = 0;
    "network.predictor.enabled" = false;
    "network.prefetch-next" = false;
    "network.trr.blocklist_cleanup_done" = true;
    "network.trr.mode" = 2;
    "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
    "pdfjs.enabledCache.state" = true;
    "pdfjs.migrationVersion" = 2;
    "pref.downloads.disable_button.edit_actions" = false;
    "pref.general.disable_button.default_browser" = false;
    "print.more-settings.open" = true;
    "privacy.donottrackheader.enabled" = true;
    "privacy.purge_trackers.date_in_cookie_database" = "0";
    "privacy.sanitize.pending" = "[{\"id\":\"newtab-container\" =\"itemsToClear\":[] =\"options\":{}}]";
    "reader.color_scheme" = "dark";
    "reader.content_width" = 5;
    "services.sync.declinedEngines" = "";
    "services.sync.engine.addresses.available" = true;
    "signon.autologin.proxy" = true;
    "signon.rememberSignons" = false;
    "trailhead.firstrun.didSeeAboutWelcome" = true;
    "widget.titlebar-x11-use-shape-mask" = true;

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

    # No Pocket
    "extensions.pocket.enabled" = false;
    "extensions.pocket.onSaveRecs" = false;

    # Prevent memory leak
    "accessibility.force_disabled" = false;

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
    "browser.uiCustomization.state" = builtins.toJSON ({
        "placements" = {
            "widget-overflow-fixed-list" = [
                "downloads-button"
                "developer-button"
                "print-button"
                "ublock0_raymondhill_net-browser-action"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "addon_darkreader_org-browser-action"
                "sponsorblocker_ajay_app-browser-action"
                "_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action"
                "jid1-kkzogwgsw3ao4q_jetpack-browser-action"
                "_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action"
                "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action"
                "_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action"
            ];
            "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "urlbar-container"
                "fxa-toolbar-menu-button"
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
        "currentVersion" = 17;
        "newElementCount" = 5;
    });
    "browser.urlbar.placeholderName" = "Google";
    "browser.urlbar.placeholderName.private" = "Google";
    "browser.urlbar.quicksuggest.migrationVersion" = 2;

    # Theme
    "devtools.theme" = "dark";
    "extensions.activeThemeID" = "default-theme@mozilla.org";

    # New Tab Page
    "browser.newtabpage.pinned" = "[]";
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

    # Fonts
    "font.default.x-western" = "sans-serif";
    "font.name.serif.x-western" = "sans-serif";
    "browser.display.use_document_fonts" = 0;

    # Allow unverified addons
    "xpinstall.signatures.required" = false;

    # Enable userChrome + userContent styling
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Allow chrome debugging
    "devtools.chrome.enabled" = true;
    "devtools.debugger.remote-enabled" = true;
    "devtools.debugger.prompt-connection" = false;
}
