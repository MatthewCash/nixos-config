lib:

# The builtin toXML function produces XML that no application I use will accept
# Create an attribute by starting the key with a "_"

let
    attrsetToList = attrset: lib.lists.zipListsWith
        (name: value: { inherit name value; })
        (builtins.attrNames attrset)
        (builtins.attrValues attrset);

    toString = exp: lib.strings.escapeXML (builtins.toString exp);
    removeUnderscore = str: builtins.substring 1 (builtins.stringLength str) str;

    getAttributes = attrset: builtins.foldl'
        (acc: cur: acc + " ${removeUnderscore cur.name}=\"${toString cur.value}\"")
        ""
        (builtins.filter (x: lib.strings.hasPrefix "_" x.name) (attrsetToList attrset));

    toXML = exp:
        if
            (builtins.isAttrs exp)
        then
            (lib.concatStringsSep "" (builtins.map (x:
                if
                    (builtins.isList x.value)
                then
                    (builtins.foldl' (acc: cur: acc + (toXML { ${x.name} = cur; })) "" x.value)
                else
                    "<${x.name}${if (builtins.isAttrs x.value) then getAttributes x.value else ""}>${toXML x.value}</${x.name}>"
            )
            (builtins.filter (x: !lib.strings.hasPrefix "_" x.name) (attrsetToList exp))))
        else
            toString exp;
in

{
    inherit toXML;
}
