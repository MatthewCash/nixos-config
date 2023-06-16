{ pkgsUnstable, stableLib, customLib, ... }:

let
    settings = import ./formatter.nix;

    settingsText = customLib.toXML {
        profiles = {
            _version = 13;
            profile = {
                _kind = "CodeFormatterProfile";
                _name = "Eclipse";
                _version = 13;
                setting = stableLib.mapAttrsToList (id: value: {
                    _id = "org.eclipse.jdt.core.formatter.${id}";
                    _value = value;
                }) settings;
            };
        };
    };
in

{
    programs.java = {
        enable = true;
        package = pkgsUnstable.jdk;
    };

    xdg.configFile."java/java-formatter.xml".text = settingsText;
}
