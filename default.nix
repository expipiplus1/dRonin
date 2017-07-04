{ pkgs ? import /home/jophish/src/nixpkgs {} }:

with pkgs;

let
  stdenv_multi = overrideCC stdenv gcc_multi;

in

stdenv_multi.mkDerivation {
  name = "dRonin";

  src = ./.;

  enableParallelBuilding = true;

  nativeBuildInputs = [
    which
    python2
    gcc-arm-embedded
    git
  ];

  postPatch = ''
    # The simulator builds as a 32 bit executable, make the 32 bit library and
    # header available as $NIX_LDFLAGS contains only 64-bit ones.
    substituteInPlace flight/PiOS/posix/library.mk --replace '-m32' \
      '-m32 -L${stdenv_multi.cc.libc.out}/lib/32 -I${stdenv_multi.cc.libc.dev}/include'
  '';

  preBuild = ''
    mkdir -p tools
    ln -s ${gcc-arm-embedded} tools/gcc-arm-none-eabi-5_2-2015q4

    mkdir -p tools/breakpad
    ln -s ${breakpad} tools/breakpad/20170224

    mkdir -p tools/Qt5.8.0/5.8/gcc_64
    ln -s ${qt58.full}/lib/qt5/* tools/Qt5.8.0/5.8/gcc_64/
    ln -s ${qt58.full}/bin tools/Qt5.8.0/5.8/gcc_64/bin
  '';

  # IGNORE_MISSING_TOOLCHAIN = true;

  buildPhase = ''
    export PACKAGE_DIR="$out"
    runHook preBuild
    make simulation
    make gcs
    # make fw_seppuku
    # make ef_seppuku
    make package_installer
  '';

  installPhase = ''
    mkdir -p $out
    false
    # mv build/uku/*.tlfw $out
    # mv build/uku/*.hex $out
  '';

  buildInputs = with qt58; [
    breakpad

    zlib
    libudev
    # qbs
    # qt58.full
    # qttools
    # qtbase
    # qtbase
    # qtcharts
    # qtimageformats
    # qtmultimedia
    # qtquickcontrols
    # qtserialport
    # qtsvg
    # qttools
  ];
}
