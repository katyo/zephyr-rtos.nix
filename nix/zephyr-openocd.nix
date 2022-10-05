{ stdenv
, lib
, fetchFromGitHub
, which
, git
, autoconf
, automake
, libtool
, texinfo
, pkg-config
, hidapi
, libftdi1
, libusb1
}:

stdenv.mkDerivation rec {
  pname = "openocd";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "zephyrproject-rtos";
    repo = "openocd";
    #rev = "zephyr-20220611";
    rev = "c5c4794";
    hash = "sha256-MHr2Lxvm12WyUIXGqkmo3BnnhFwLqu+9Xz92vVX+gFs=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  nativeBuildInputs = [ which git autoconf automake libtool texinfo pkg-config ];

  buildInputs = [ hidapi libftdi1 libusb1 ];

  preConfigure = ''
    ./bootstrap
  '';

  configureFlags = [
    "--enable-jtag_vpi"
    "--enable-usb_blaster_libftdi"
    (lib.enableFeature (! stdenv.isDarwin) "amtjtagaccel")
    (lib.enableFeature (! stdenv.isDarwin) "gw16012")
    "--enable-presto_libftdi"
    "--enable-openjtag_ftdi"
    (lib.enableFeature (! stdenv.isDarwin) "oocd_trace")
    "--enable-buspirate"
    (lib.enableFeature stdenv.isLinux "sysfsgpio")
    "--enable-remote-bitbang"
  ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isGNU [
    "-Wno-error=cpp"
    "-Wno-error=strict-prototypes" # fixes build failure with hidapi 0.10.0
  ];

  postInstall = lib.optionalString stdenv.isLinux ''
    mkdir -p "$out/etc/udev/rules.d"
    rules="$out/share/openocd/contrib/60-openocd.rules"
    if [ ! -f "$rules" ]; then
        echo "$rules is missing, must update the Nix file."
        exit 1
    fi
    ln -s "$rules" "$out/etc/udev/rules.d/"
  '';
}
