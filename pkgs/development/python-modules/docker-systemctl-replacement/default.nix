{ lib
, python3
, buildPythonPackage
, fetchPypi
}:


buildPythonPackage
rec {
  pname = "docker-systemctl-replacement";
  version = "1.5.7417";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-DqHJdblx6By60mMlCAJ1H9W44Ydk8T9Wcfh8X1mfwsw=";
  };


  meta = with lib; {
    description = "Docker systemctl replacement - allows to deploy to systemd-controlled containers without starting an actual systemd daemon (e.g. centos7, ubuntu16)";
    homepage = "https://github.com/gdraheim/docker-systemctl-replacement/";
    license = licenses.eupl12;
    maintainers = with maintainers; [ tennox ];
    mainProgram = "systemctl.py";
  };
}
