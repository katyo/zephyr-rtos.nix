{ pkgs ? import ./packages.nix {}, inputs ? [], toolchains ? "all", ... }:

let zephyr-sdk = pkgs.zephyr-sdk.override {
      inherit toolchains;
    };

in pkgs.gccMultiStdenv.mkDerivation {
  name = "zephyr-rtos-env";

  phases = [];

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
    SDL2
    xz
    file
    # net-tools support
    pkgconfig
    glib
    libpcap
    # toolchain
    zephyr-sdk
    pahole
    openocd-svd
    hidrd
  ] ++ (with pkgs.python3Packages; [
    anytree
    pyelftools
    venvShellHook
    west
  ]) ++ inputs;

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
    if [ -d .venv ]
    then
      echo 'Virtual env already initialized...'
      source .venv/bin/activate
    else
      python -m venv .venv
      source .venv/bin/activate
      pip install -r zephyr/scripts/requirements.txt
      pip install git+https://github.com/HBehrens/puncover
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
}
