{ pkgs }:

{ name ? "zephyr-rtos-env"
, inputs ? [ ]
, toolchains ? "all"
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
  inherit name;

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

  shellHook = ''
    if [ -d .west ]
    then
      echo 'Workspace already initialized...'
    else
      west init
      west update
    fi
    source <(west completion bash)
    echo
    echo '__              '
    echo ' / _ ._ |_   ._ '
    echo '/_(/_|_)| |\/|  '
    echo '     |     /    '
    echo
    echo 'Zephyr workspace successfully configured.'
    echo
    echo 'You can try build and run demo:'
    echo '  west build -p auto -b qemu_x86 zephyr/samples/hello_world'
    echo '  west build -t run'
  '';
})
