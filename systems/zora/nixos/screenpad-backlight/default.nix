{ stdenv, kernel }:

stdenv.mkDerivation {
  pname = "asus-screenpad-backlight";
  version = "0.8.0";
  src = ./.;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$PWD modules
  '';

  installPhase = ''
    install -Dm444 asus_screenpad_backlight.ko \
      $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/asus_screenpad_backlight.ko
  '';
}
