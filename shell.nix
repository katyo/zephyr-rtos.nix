{ pkgs ? import ./packages.nix {}, version ? "1.0.1", inputs ? [], toolchains ? "all", ... }:

let zephyr-sdk = pkgs.zephyr-sdk.override {
      inherit version toolchains;
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
    gcc13
    xz
    file
    # net-tools support
    pkg-config
    glib
    libpcap
    # toolchain
    zephyr-sdk
    zephyr-openocd
    pahole
    openocd-svd
    hidrd
    autoPatchelfHook
  ] ++ (with pkgs.python312Packages; [
    anytree
    pyelftools
    venvShellHook
    west
    jsonschema
  ]) ++ inputs;

  ZEPHYR_TOOLCHAIN_VARIANT = "zephyr";
  ZEPHYR_SDK_INSTALL_DIR = "${zephyr-sdk}/zephyr-sdk";

  shellHook = ''
    _prepareZephyr() {
      source <(west completion bash)
      echo 'Zephyr workspace successfully configured.'
      echo
      echo 'You can try build and run demo:'
      echo '  west build -p auto -b qemu_x86 zephyr/samples/hello_world'
      echo '  west build -t run'
    }
    _initialZephyr() {
      echo 'You need install Zephyr to continue:'
      echo '  prepareZephyr'
    }
    prepareZephyr() {
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
        autoPatchelf .venv
      fi
      prepareZephyr
    }
    echo
    echo '__              '
    echo ' / _ ._ |_   ._ '
    echo '/_(/_|_)| |\/|  '
    echo '     |     /    '
    echo
    if [ -d .west -a -d .venv ]
    then
      _prepareZephyr
    else
      _initialZephyr
    fi
  '';
}
