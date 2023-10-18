{ stdenv, fetchurl, mono, gtk-sharp-2_0, screen, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "renode";
  version = "1.13.2";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}-${version}.linux-portable.tar.gz";
    hash = "sha256-OvOlOELZ1eR3DURCoPe+WCvVyVm6DPKNcC1V7uauCjY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  propagatedBuildInputs = [
    mono
    gtk-sharp-2_0
    screen
  ];

  installPhase = ''
    install -d $out/renode $out/bin
    cp -r * .renode-root $out/renode
    ln -s $out/renode/renode $out/bin/renode
  '';
}
