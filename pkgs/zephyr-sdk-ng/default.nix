{ stdenv, lib, hostPlatform, fetchurl, autoPatchelfHook, makeBinaryWrapper, xz, python38, which
, hidapi, libftdi1, libusb1, overrideOpenocd, cmake, wget, file
, version ? "0.16.5", toolchains ? "all" }:

let pname = "zephyr-sdk";
    system = lib.splitString "-" hostPlatform.system;
    host = "${lib.elemAt system 1}-${lib.elemAt system 0}";
    base-url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/";
    hashes = (import ./zephyr-sdk-hash.nix).${version}.${host};
    install-toolchains = if toolchains == "all"
      then builtins.trace "All toolchains will be installed. This may take a long..."
             (builtins.attrNames hashes.toolchains)
      else toolchains;

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
  buildInputs = [ xz python38 hidapi libftdi1 libusb1 ];

  postUnpack = ''
    mv ${lib.concatStringsSep " " install-toolchains} $sourceRoot
  '';

  dontAutoPatchelf = true;
  postFixup = ''
    autoPatchelf $(find $out/zephyr-sdk -mindepth 1 -maxdepth 1 -type d -not -name sysroots)

    find $out -type f -perm -a+x -name '*-py' | while read prog; do
      echo "Wrap python program: $prog"
      wrapProgram $prog \
        --set NIX_PYTHONPREFIX ${python38} \
        --set NIX_PYTHONEXECUTABLE ${python38}/bin/python3.8 \
        --set NIX_PYTHONPATH ${python38}/lib/python3.8/site-packages
    done
  '';

  configurePhase = "true";
  buildPhase = "true";
  installPhase = ''
    install -d -m0755 $out/zephyr-sdk
    mv * $out/zephyr-sdk
    patchShebangs --host $out/zephyr-sdk
    (cd $out/zephyr-sdk && ./setup.sh -h ${lib.concatMapStringsSep " " (toolchain: "-t ${toolchain}") install-toolchains})
    #find -maxdepth 1 -! -name '*.sh' -exec cp -r {} $out/zephyr-sdk \;
  '' + (lib.optionalString (overrideOpenocd != null) ''
    rm -f $out/zephyr-sdk/sysroots/x86_64-pokysdk-linux/usr/bin/openocd
    ln -s ${overrideOpenocd}/bin/openocd \
       $out/zephyr-sdk/sysroots/x86_64-pokysdk-linux/usr/bin/openocd
  '');
}
