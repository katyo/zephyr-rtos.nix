{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, nix-update-script

, glibcLocales
, python3Packages

, gtk-sharp-2_0
, gtk2-x11
, screen
}:

let

  pythonLibs = with python3Packages; makePythonPath [
    construct
    psutil
    pyyaml
    requests
    robotframework
  ];

in

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

  nativeBuildInputs = [ autoPatchelfHook ];

  propagatedBuildInputs = [
    gtk2-x11
    gtk-sharp-2_0
    screen
  ];

  strictDeps = true;

  installPhase = ''
    mkdir -p $out/{bin,libexec/renode}

    mv * $out/libexec/renode
    mv .renode-root $out/libexec/renode
    chmod +x $out/libexec/renode/*.so

    cat > $out/bin/renode <<EOF
    #!${stdenv.shell}
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export PATH="$out/libexec/renode:\$PATH"
    export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${gtk2-x11}/lib
    exec renode "\$@"
    EOF

    cat > $out/bin/renode-test <<EOF
    #!${stdenv.shell}
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export PYTHONPATH="${pythonLibs}:\$PYTHONPATH"
    export PATH="$out/libexec/renode:\$PATH"
    export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${gtk2-x11}/lib
    exec renode-test "\$@"
    EOF

    substituteInPlace $out/libexec/renode/renode-test \
      --replace '$PYTHON_RUNNER' '${python3Packages.python}/bin/python3'

    chmod +x $out/bin/renode $out/bin/renode-test
  '';

  meta = {
    description = "Virtual development framework for complex embedded systems";
    homepage = "https://renode.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = [ "x86_64-linux" ];
  };
}
