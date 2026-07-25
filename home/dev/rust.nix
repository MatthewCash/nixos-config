{ pkgsUnstable, config, ... }:

{
    home.packages = with pkgsUnstable; [
        cargo
        clippy
        rustc
        rustfmt
    ];

    home.sessionVariables = {
        RUST_SRC_PATH = "${pkgsUnstable.rust.packages.stable.rustPlatform.rustLibSrc}";
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
    };
}
