{ stdenv, fetchurl, mono, gtk-sharp-2_0, screen, autoPatchelfHook, nix-update-script }:
stdenv.mkDerivation rec {
  pname = "renode";
  version = "1.14.0+20231018gite86ec009";

  src = fetchurl {
    url = "https://builds.renode.io/${pname}-${version}.linux-portable.tar.gz";
    hash = "sha256-Tuc5C2mE10DseWvjkd3Xs+8GK+28oRR5/TxTuXGz62E=";
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
