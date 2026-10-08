{ lib, stdenv, fetchFromGitHub, fetchurl, cmake, ninja, unzip, pkg-config
, llvmPackages_22, pcre2, portaudio, portmidi, rtmidi, libsndfile, gtest, alsa-lib }:

# Extempore against nixpkgs' libraries. Upstream's CMake downloads and builds
# its own LLVM, PCRE2, PortAudio, audio libraries and GoogleTest;
# system-deps.patch adds EXTEMPORE_SYSTEM_DEPS, which finds installed ones
# instead. kiss_fft is Extempore's fork, which nixpkgs does not carry, so it
# is built here.

let
  version = "0.11.2";

  kiss_fft = stdenv.mkDerivation {
    pname = "extempore-kiss_fft";
    version = "1.3.0";
    src = fetchurl {
      url = "https://github.com/extemporelang/kiss_fft/archive/1.3.0.zip";
      sha256 = "fd6d82f4aa4a22d2fc3d192a66b919abf43b9c001b78585dc5c3290218981fcd";
    };
    nativeBuildInputs = [ cmake unzip ];
    # Its CMakeLists asks for 3.0, which CMake 4 refuses.
    cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  };
in
stdenv.mkDerivation {
  pname = "extempore";
  inherit version;

  src = fetchFromGitHub {
    owner = "digego";
    repo = "extempore";
    rev = "v${version}";
    hash = "sha256-NjgiYoyircxlEHfqEFwlbbTZ4MtrW1h0qGqYT8IzAT0=";
  };

  patches = [ ./system-deps.patch ];

  nativeBuildInputs = [ cmake ninja pkg-config ];
  buildInputs = [ llvmPackages_22.llvm pcre2 portaudio portmidi rtmidi libsndfile kiss_fft alsa-lib ];
  checkInputs = [ gtest ];

  # The tree installs as upstream's release archive is laid out: the binary
  # with runtime/, libs/ and examples/ beside it, which is where it looks for
  # them. EXT_SHARE_DIR stays upstream's default, the source tree, because the
  # AOT step and the tests run the not-yet-installed binary from build/ and
  # that is the fallback it reads.
  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}/share/extempore"
    "-DEXTEMPORE_SYSTEM_DEPS=ON"
    "-DEXTEMPORE_VERSION=v${version}"
    (lib.cmakeBool "BUILD_TESTS" true)
  ];

  # The label set upstream's CI runs (.github/workflows/build-and-test.yml).
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ctest --parallel $NIX_BUILD_CORES --output-on-failure \
      --label-regex "libs-core|libs-external|compiler-unit|cpp-unit|examples-core|examples-audio|audio-offline"
    runHook postCheck
  '';

  postInstall = ''
    mkdir -p $out/bin
    ln -s ../share/extempore/extempore $out/bin/extempore
  '';

  meta = {
    description = "Live-coding environment for music, audio and graphics (xtlang + Scheme)";
    homepage = "https://github.com/digego/extempore";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "extempore";
  };
}
