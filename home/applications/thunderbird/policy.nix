{ inputs, system, ... }:

{
    DisableAppUpdate = true;
    DontCheckDefaultBrowser = true;
    DisableTelemetry = true;
    ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        "addon@darkreader.org" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
        "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/localcdn-fork-of-decentraleyes/latest.xpi";
        };
        "owl@beonex.com" = {
            installation_mode = "normal_installed";
            install_url = "file://${inputs.owl-patched.defaultPackage.${system}}/addon/owl.xpi";
        };
        "main-theme@matthew-cash.com" = {
            installation_mode = "normal_installed";
            install_url = "file://${inputs.mozilla-theme.defaultPackage.${system}}/addon/theme.xpi";
            allowed_types = [ "theme" ];
        };
    };
}
