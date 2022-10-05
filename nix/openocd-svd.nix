{ fetchFromGitHub, python3, qt5 }:
python3.pkgs.buildPythonApplication rec {
  pname = "openocd-svd";
  git-rev = "28bfab1";
  version = "1.0-git${git-rev}";

  src = fetchFromGitHub rec {
    owner = "esynr3z";
    repo = "openocd-svd";
    rev = "${git-rev}";
    name = "${pname}-${version}";
    sha256 = "09q4l70v7rbxg7924fz37njsnfwh6l6by2x8xwc58x100i1ylxj8";
  };

  format = "other";

  nativeBuildInputs = with qt5; [ wrapQtAppsHook ];
  propagatedBuildInputs = with python3.pkgs; [ setuptools cmsis-svd pyqt5 ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r app/*.py $out/bin
    mv $out/bin/openocd_svd.py $out/bin/openocd-svd
  '';

  postFixup = ''
    wrapQtApp $out/bin/openocd-svd
  '';

  doCheck = false;
}
