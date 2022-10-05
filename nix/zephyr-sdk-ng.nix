{ stdenv, lib, hostPlatform, fetchurl, autoPatchelfHook, xz, python38, which
, hidapi, libftdi1, libusb1, overrideOpenocd, cmake, wget, file
, version ? "0.15.1", toolchains ? "all" }:

let pname = "zephyr-sdk";
    system = lib.splitString "-" hostPlatform.system;
    host = "${lib.elemAt system 1}-${lib.elemAt system 0}";
    pkg-ext = if (lib.elemAt system 1) == "windows" then ".zip" else ".tar.gz";
    base-url = "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${version}/";
    minimal-url = "${base-url}${pname}-${version}_${host}_minimal${pkg-ext}";
    toolchain-url = toolchain: "${base-url}toolchain_${host}_${toolchain}${pkg-ext}";
    hashes = (import ./zephyr-sdk-hash.nix).${version}.${host};
    install-toolchains = if toolchains == "all" then builtins.attrNames hashes.toolchains else toolchains;

in stdenv.mkDerivation {
  inherit pname version;

  srcs = [
    (fetchurl {
      url = minimal-url;
      hash = hashes.minimal;
    })
  ] ++ (map (toolchain: fetchurl {
    url = toolchain-url toolchain;
    hash = hashes.toolchains.${toolchain};
  }) install-toolchains);

  sourceRoot = "${pname}-${version}";

  nativeBuildInputs = [ autoPatchelfHook which file cmake wget ];
  buildInputs = [ xz python38 hidapi libftdi1 libusb1 ];

  postUnpack = ''
    mv ${lib.concatStringsSep " " install-toolchains} $sourceRoot
  '';

  configurePhase = "true";
  buildPhase = "true";
  installPhase = ''
    install -d -m0755 $out/zephyr-sdk
    mv * $out/zephyr-sdk
    patchShebangs --host $out/zephyr-sdk
    (cd $out/zephyr-sdk && ./setup.sh -h ${lib.concatMapStringsSep " " (toolchain: "-t ${toolchain}") install-toolchains})
    #find -maxdepth 1 -! -name '*.sh' -exec cp -r {} $out/zephyr-sdk \;
  '' + (if overrideOpenocd == null then "" else ''
    rm -f $out/zephyr-sdk/sysroots/x86_64-pokysdk-linux/usr/bin/openocd
    ln -s ${overrideOpenocd}/bin/openocd \
       $out/zephyr-sdk/sysroots/x86_64-pokysdk-linux/usr/bin/openocd
  '');
}
