{ inputs, system, accentColor, ... }:

let
    mozilla-theme = inputs.mozilla-theme.defaultPackage.${system}.override { inherit accentColor; };
in

{
    DisableAppUpdate = true;
    DontCheckDefaultBrowser = true;
    DisablePocket = true;
    DisableTelemetry = true;
    ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
        "idcac-pub@guus.ninja" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
        };
        "{7c7f6dea-3957-4bb9-9eec-2ef2b9e5bcec}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ultimadark/latest.xpi";
        };
        "sponsorBlocker@ajay.app" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        };
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
        };
        "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/localcdn-fork-of-decentraleyes/latest.xpi";
        };
        "main-theme@matthew-cash.com" = {
            installation_mode = "normal_installed";
            install_url = "file://${mozilla-theme}/addon/theme.xpi";
            allowed_types = [ "theme" ];
        };
    };
    Handlers = {
        mimeTypes = {
            "application/pdf" = {
                action = 3;
                extensions = [ "pdf" ];
            };
        };
    };
}
