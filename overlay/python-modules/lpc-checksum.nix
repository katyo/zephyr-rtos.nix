{ lib
, buildPythonPackage
, fetchPypi
, poetry-core
, intelhex
}:

buildPythonPackage rec {
  pname = "lpc-checksum";
  version = "3.0.0";
  pyproject = true;

  src = fetchPypi {
    pname = "lpc_checksum";
    inherit version;
    hash = "sha256-RNXujNYpGrh1KH+ZuU9ExbXmzonivJyISgi7h81NrNQ=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    intelhex
  ];

  pythonImportsCheck = [ "lpc_checksum" ];

  meta = with lib; {
    description = "Python script to calculate LPC firmware checksums";
    homepage = "https://pypi.org/project/lpc-checksum/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
