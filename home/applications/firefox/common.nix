{ pkgsStable, ... }:

{
    search = {
        force = true;
        engines = {
            "Nix packages" = {
                urls = [{
                    template = "https://search.nixos.org/packages";
                    params = [
                        { name = "type"; value = "packages"; }
                        { name = "query"; value = "{searchTerms}"; }
                    ];
                }];
                icon = "${pkgsStable.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "nixp" ];
            };

            "Wikipedia" = {
                urls = [{ template = "https://"; }];
                iconUpdateURL = "https://upload.wikimedia.org/wikipedia/en/8/80/Wikipedia-logo-v2.svghttps://upload.wikimedia.org/wikipedia/en/8/80/Wikipedia-logo-v2.svg";
                definedAliases = [ "wiki"];
            };
        };
    };
}
