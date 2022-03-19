{ pkgs, persistenceHomePath, name, ... }:

let
    firefox-devedition-bin = pkgs.firefox-devedition-bin.override (old: {
        icon = "firefox-developer-edition";
        desktopName = "Firefox Developer Edition";
        nameSuffix = ""; 
        forceWayland = true;
        extraPolicies = {
            DisableAppUpdate = true;
            DontCheckDefaultBrowser = true;
            DisablePocket = true;
        };
    });
in

{
    home.persistence."${persistenceHomePath}/${name}".directories = [
        ".mozilla"
        ".cache/mozilla"
    ];

    programs.firefox = {
        enable = true;
        package = firefox-devedition-bin;
        profiles = {
            "main.devedition-default" = {
                isDefault = true;
                settings = {
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
                    "security.sandbox.content.level" = 0;
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
                };
            };
        };
    };
}
