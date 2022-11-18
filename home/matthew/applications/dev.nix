{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [
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
        RUST_SRC_PATH = "${pkgsUnstable.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
}
