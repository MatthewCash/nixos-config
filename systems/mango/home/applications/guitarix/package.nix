{ pkgsUnstable, skin }:

pkgsUnstable.symlinkJoin {
    name = "guitarix-targeting-computer";
    paths = [ pkgsUnstable.guitarix ];
    nativeBuildInputs = [ pkgsUnstable.makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/guitarix \
            --add-flags "--style-dir ${skin}/" \
            --add-flags "--rcset Nebula" \
            --add-flags "--no-watchdog-warning"
    '';
}
