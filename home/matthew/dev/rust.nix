{ pkgsUnstable, ... }:

{
    home.packages = with pkgsUnstable; [
        cargo
        rustc
    ];

    home.sessionVariables = {
        RUST_SRC_PATH = "${pkgsUnstable.rust.packages.stable.rustPlatform.rustLibSrc}";
    };
}
