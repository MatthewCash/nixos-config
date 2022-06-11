{ pkgs, ... }:

{
    home.packages = with pkgs; [
        gcc
        gdb
        gnumake
        binutils

        # Rust
        cargo
        rustc
        rustfmt

        # Java
        maven
    ];

    home.sessionVariables = {
        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
}
