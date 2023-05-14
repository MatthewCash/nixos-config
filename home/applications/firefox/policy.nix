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
        "addon@darkreader.org" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
        "sponsorBlocker@ajay.app" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        };
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
        };
        "{bca78169-de5a-4ac1-8fbd-8e768795427e}" = {
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