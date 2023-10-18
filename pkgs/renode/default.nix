{ stdenv, fetchurl, mono, gtk-sharp-2_0, screen, autoPatchelfHook, nix-update-script }:
stdenv.mkDerivation rec {
  pname = "renode";
  version = "1.14.0";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}-${version}.linux-portable.tar.gz";
    hash = "sha256-1wfVHtCYc99ACz8m2XEg1R0nIDh9xP4ffV/vxeeEHxE=";
  };

  passthru = {
    updateScript = nix-update-script { };
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
