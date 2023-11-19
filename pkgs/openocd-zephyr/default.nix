{ stdenv
, lib
, fetchurl
, autoreconfHook
, pkg-config
, hidapi
, jimtcl
, libjaylink
, libusb1
, libgpiod_1

, enableFtdi ? true, libftdi1

# Allow selection the hardware targets (SBCs, JTAG Programmers, JTAG Adapters)
, extraHardwareSupport ? []
}:
let
  isPatchFile = name: value: value == "regular" && (lib.hasSuffix ".patch" name);
  filesFromDir = filt: path: map (name: path + "/${name}")
    (lib.naturalSort (lib.attrNames (lib.filterAttrs filt (builtins.readDir path))));
in
stdenv.mkDerivation rec {
  pname = "openocd";
  version = "0.12.0";
  src = fetchurl {
    url = "mirror://sourceforge/project/${pname}/${pname}/${version}/${pname}-${version}.tar.bz2";
    sha256 = "sha256-ryVHiL6Yhh8r2RA/5uYKd07Jaow3R0Tu+Rl/YEMHWvo=";
  };

  # Patches from https://github.com/zephyrproject-rtos/openocd
  patches = filesFromDir isPatchFile ./.;

  nativeBuildInputs = [ pkg-config autoreconfHook ];

  buildInputs = [ hidapi jimtcl libftdi1 libjaylink libusb1 ]
    ++ lib.optional stdenv.isLinux libgpiod_1;

  configureFlags = [
    "--disable-werror"
    "--disable-internal-jimtcl"
    "--disable-internal-libjaylink"
    "--enable-jtag_vpi"
    "--enable-buspirate"
    "--enable-remote-bitbang"
    (lib.enableFeature enableFtdi "ftdi")
    (lib.enableFeature stdenv.isLinux "linuxgpiod")
    (lib.enableFeature stdenv.isLinux "sysfsgpio")
  ] ++
    map (hardware: "--enable-${hardware}") extraHardwareSupport
  ;

  enableParallelBuilding = true;

  env.NIX_CFLAGS_COMPILE = toString (lib.optionals stdenv.cc.isGNU [
    "-Wno-error=cpp"
    "-Wno-error=strict-prototypes" # fixes build failure with hidapi 0.10.0
  ]);

  postInstall = lib.optionalString stdenv.isLinux ''
    mkdir -p "$out/etc/udev/rules.d"
    rules="$out/share/openocd/contrib/60-openocd.rules"
    if [ ! -f "$rules" ]; then
        echo "$rules is missing, must update the Nix file."
        exit 1
    fi
    ln -s "$rules" "$out/etc/udev/rules.d/"
  '';

  meta = with lib; {
    description = "Free and Open On-Chip Debugging, In-System Programming and Boundary-Scan Testing";
    longDescription = ''
      OpenOCD provides on-chip programming and debugging support with a layered
      architecture of JTAG interface and TAP support, debug target support
      (e.g. ARM, MIPS), and flash chip drivers (e.g. CFI, NAND, etc.).  Several
      network interfaces are available for interactiving with OpenOCD: HTTP,
      telnet, TCL, and GDB.  The GDB server enables OpenOCD to function as a
      "remote target" for source-level debugging of embedded systems using the
      GNU GDB program.
    '';
    homepage = "https://openocd.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ bjornfor prusnak ];
    platforms = platforms.unix;
  };
}
