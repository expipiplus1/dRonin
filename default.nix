{ pkgs ? import /home/jophish/src/nixpkgs {} }:

with pkgs;

stdenv.mkDerivation {
  name = "dRonin";

  src = ./.;

  enableParallelBuilding = true;

  nativeBuildInputs = [
    which
    python2
    gcc-arm-embedded
    git
  ];

  preBuild = ''
    mkdir -p tools
    ln -s ${gcc-arm-embedded} tools/gcc-arm-none-eabi-5_2-2015q4

    mkdir -p tools/breakpad
    ln -s ${breakpad} tools/breakpad/20170224

    mkdir -p tools/Qt5.8.0/5.8/gcc_64
    ln -s $NIX_BUILD_TOP/__nix_qt5__/lib/qt-5.8/plugins tools/Qt5.8.0/5.8/gcc_64/
    ln -s $NIX_BUILD_TOP/__nix_qt5__/bin tools/Qt5.8.0/5.8/gcc_64/
  '';

  # IGNORE_MISSING_TOOLCHAIN = true;

  buildPhase = ''
    export PACKAGE_DIR="$out"
    runHook preBuild
    # make gcs
    make fw_seppuku
    make ef_seppuku
    # make package_installer
  '';

  installPhase = ''
    mkdir -p $out
    mv build/uku/*.tlfw $out
    mv build/uku/*.hex $out
  '';

  buildInputs = with qt58; [
    breakpad

    qbs
    qtbase
    qtcharts
    qtimageformats
    qtmultimedia
    qtquickcontrols
    qtserialport
    qtsvg 
    qttools
  ];
}
