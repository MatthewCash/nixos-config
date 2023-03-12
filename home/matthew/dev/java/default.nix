{ pkgsUnstable, stableLib, ... }:

let
    settings = import ./formatter.nix;

    valueToString = value: 
        if (builtins.isBool value) then (stableLib.boolToString value) else (builtins.toString value);

    convertLineToXml = id: value:
        "<setting id=\"org.eclipse.jdt.core.formatter.${id}\" value=\"${valueToString value}\" />";

    settingsLines = builtins.mapAttrs convertLineToXml settings;
    settingsText = ''
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <profiles version="13">
        <profile kind="CodeFormatterProfile" name="Eclipse" version="13">
            ${builtins.concatStringsSep "\n        " (builtins.attrValues settingsLines)}
        </profile>
    </profiles>
    '';
in

{
    programs.java = {
        enable = true;
        package = pkgsUnstable.jdk;
    };

    xdg.configFile."java/java-formatter.xml".text = settingsText;
}
