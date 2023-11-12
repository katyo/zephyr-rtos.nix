{ pkgs }:

{ name ? "zephyr-rtos-env"
, inputs ? [ ]
, toolchains ? "all"
, shellHook ? null
}:
let
  zephyr-sdk = pkgs.zephyr-sdk.override {
    inherit toolchains;
  };

  pythonEnv = with pkgs.python3Packages; [
    anytree
    canopen
    cbor
    colorama
    coverage
    gcovr
    graphviz
    grpcio-tools
    imgtool
    intelhex
    junit2html
    junitparser
    lpc-checksum
    lxml
    mock
    mypy
    natsort
    packaging
    pillow
    ply
    progress
    protobuf
    psutil
    pyelftools
    PyGithub
    pykwalify
    pylink-square
    pylint
    pyocd
    pyserial
    pytest
    python-magic
    pyyaml
    requests
    tabulate
    west
    yamllint
    zcbor
  ];
in

pkgs.gccMultiStdenv.mkDerivation ({
  inherit name shellHook;

  phases = [ ];

  buildInputs = with pkgs; [
    git
    cmake
    ninja
    gnumake
    clang-tools
    gperf
    ccache
    dfu-util
    dtc
    wget
    gcc11
    xz
    file
    # net-tools support
    pkg-config
    glib
    libpcap
    pahole
    openocd-svd
    hidrd
    gitlint

    # toolchain
    zephyr-sdk
    pythonEnv
  ] ++ inputs;

  ZEPHYR_TOOLCHAIN_VARIANT = "zephyr";
  ZEPHYR_SDK_INSTALL_DIR = "${zephyr-sdk}/zephyr-sdk";
})
