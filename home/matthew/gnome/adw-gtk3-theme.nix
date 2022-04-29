# Adapted from https://github.com/NixOS/nixpkgs/issues/162432#issuecomment-1056928781

{ 
    stdenvNoCC,
    lib,
    fetchFromGitHub,
    nix-update-script,
    meson,
    ninja,
    sassc,
}:

stdenvNoCC.mkDerivation rec {
    pname = "adw-gtk3";
    version = "1.7";

    src = fetchFromGitHub {
        owner = "lassekongo83";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-FHB1lYc1EFktuYTjFVWaZ5l4xkhkUeXGT6KwUjUNtn4=";
    };

    nativeBuildInputs = [
        meson
        ninja
        sassc
    ];

    postPatch = ''
        chmod +x gtk/src/adw-gtk3-dark/gtk-3.0/install-dark-theme.sh
        patchShebangs gtk/src/adw-gtk3-dark/gtk-3.0/install-dark-theme.sh
    '';

    passthru = {
        updateScript = nix-update-script {
            attrPath = pname;
        };
    };

    meta = with lib; {
        description = "The theme from libadwaita ported to GTK-3";
        homepage = "https://github.com/lassekongo83/adw-gtk3";
        license = licenses.lgpl21Only;
        platforms = platforms.linux;
        maintainers = with maintainers; [ /* TODO */ ];
    };
}
