{ stdenv, lib, fetchurl, autoPatchelfHook, makeBinaryWrapper, xz, python311, python312, which
, hidapi, libftdi1, libusb1, ncurses, libxcrypt-legacy, overrideOpenocd ? null, cmake, wget, file
, version ? "1.0.1", toolchains ? "all" }:

let pname = "zephyr-sdk";
    system = lib.splitString "-" stdenv.hostPlatform.system;
    host = "${lib.elemAt system 1}-${lib.elemAt system 0}";
    base-url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/";
    hashes = (import ./zephyr-sdk-hash.nix).${version}.${host};
    install-toolchains = if toolchains == "all"
      then builtins.trace "All toolchains will be installed. This may take a long..."
             (builtins.attrNames hashes.toolchains)
      else toolchains;

    version_major = builtins.elemAt (builtins.splitVersion version) 0;
    is_ng = version_major != "0";

    python = if is_ng then python312 else python311;
    py-ver = if is_ng then "3.12" else "3.10";

in stdenv.mkDerivation {
  inherit pname version;

  srcs = [
    (fetchurl {
      url = "${base-url}${hashes.minimal.file}";
      hash = hashes.minimal.hash;
    })
  ] ++ (map (toolchain: fetchurl {
    url = "${base-url}${hashes.toolchains.${toolchain}.file}";
    hash = hashes.toolchains.${toolchain}.hash;
  }) install-toolchains);

  sourceRoot = "${pname}-${version}";

  nativeBuildInputs = [ autoPatchelfHook makeBinaryWrapper which file cmake wget ];
  buildInputs = [ xz python hidapi libftdi1 libusb1 ncurses libxcrypt-legacy ];

  postUnpack = ''
    ${lib.optionalString is_ng "mkdir -p $sourceRoot/gnu"}
    ${lib.concatMapStringsSep "\n"
      (toolchain: "mv ${toolchain} ${if is_ng && toolchain != "llvm" then "$sourceRoot/gnu" else "$sourceRoot"}")
      install-toolchains}
  '';

  dontAutoPatchelf = true;
  postFixup = ''
    ${lib.optionalString (!is_ng) ''
      find $out -type f -perm -a+x -name '*-py' | while read prog; do
        echo "Patch python program: $prog"
        patchelf --replace-needed libpython3.10.so.1.0 libpython3.11.so.1.0 $prog || true
      done
    ''}

    autoPatchelf $(find $out/zephyr-sdk -mindepth 1 -maxdepth 1 -type d -not -name sysroots)

    find $out -type f -perm -a+x -name '*-py' | while read prog; do
      echo "Wrap python program: $prog"
      wrapProgram $prog \
        --set NIX_PYTHONPREFIX ${python} \
        --set NIX_PYTHONEXECUTABLE ${python}/bin/python${py-ver} \
        --set NIX_PYTHONPATH ${python}/lib/python${py-ver}/site-packages
    done
  '';

  configurePhase = "true";
  buildPhase = "true";
  installPhase = ''
    install -d -m0755 $out/zephyr-sdk
    mv * $out/zephyr-sdk
    patchShebangs --host $out/zephyr-sdk
    find $out -type d -maxdepth 2
    (cd $out/zephyr-sdk && ./setup.sh -h ${lib.concatMapStringsSep " " (toolchain: if toolchain == "llvm" then "-l" else "-t ${toolchain}") install-toolchains})
    #find -maxdepth 1 -! -name '*.sh' -exec cp -r {} $out/zephyr-sdk \;
  '' + (lib.optionalString (overrideOpenocd != null) ''
    rm -f $out/zephyr-sdk/sysroots/x86_64-pokysdk-linux/usr/bin/openocd
    ln -s ${overrideOpenocd}/bin/openocd \
       $out/zephyr-sdk/sysroots/x86_64-pokysdk-linux/usr/bin/openocd
  '');
}
