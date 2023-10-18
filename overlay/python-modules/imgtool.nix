{ lib
, fetchPypi
, buildPythonPackage
, setuptools
, wheel
, cbor2
, click
, cryptography
, intelhex
}:

buildPythonPackage rec {
  pname = "imgtool";
  version = "1.10.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-A7NOdZNKw9lufEK2vK8Rzq9PRT98bybBfXJr0YMQS0A=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    cbor2
    click
    cryptography
    intelhex
  ];

  doCheck = false;

  pythonImportsCheck = [ "imgtool" ];

  meta = with lib; {
    description = "MCUboot's image signing and key management";
    homepage = "https://pypi.org/project/imgtool";
    license = licenses.asl20;
    maintainers = with maintainers; [ otavio ];
    mainProgram = "imgtool";
  };
}
