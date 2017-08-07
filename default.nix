{ pkgs ? import /home/jophish/src/nixpkgs {} }:

with pkgs;

let
  # The simulator is a 32 bit executable
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
    zip
    unzip
    file
    dpkg
    fakeroot
  ];

  buildInputs = with qt58; [
    breakpad
    zlib
    libudev
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

  buildPhase = ''
    export PACKAGE_DIR="$out"
    runHook preBuild

    make simulation -j $NIX_BUILD_CORES
    make gcs -j $NIX_BUILD_CORES
    make package_flight -j $NIX_BUILD_CORES
    make package_all_compress
  '';

  installPhase = ''
    cp -r build/package-linux_*-dirty/dronin_linux_*-dirty "$out"
    cp -r build/package-linux_*-dirty/rules.udev "$out"
  '';
}
