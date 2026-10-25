{ stdenv, kernel, kernelModuleMakeFlags }:

stdenv.mkDerivation {
  pname = "asus-screenpad-backlight";
  version = "0.8.0";
  src = ./.;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];

  buildFlags = [ "modules" ];
  installFlags = [
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=kernel/drivers/platform"
  ];
  installTargets = [ "modules_install" ];
}
