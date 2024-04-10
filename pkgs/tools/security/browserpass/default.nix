{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, gnupg
, makeWrapper
, autoPatchelfHook
, testers
, browserpass
}:

buildGoModule rec {
  pname = "browserpass";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "tennox";
    repo = "browserpass-native";
    rev = "c4c71108293b259bf592ec5d9a7f13559a5f8fca";
    sha256 = "sha256-hYvdKPme719qpOnGGwvrlhNelLtbGwLngI5ggmVUahA=";
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  vendorHash = "sha256-Qihtt86MrCaFqxWnS57vxNPWwD6ZYt9ESJFyUp+uCXQ=";

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postPatch = ''
    # Because this Makefile will be installed to be used by the user, patch
    # variables to be valid by default
    substituteInPlace Makefile \
      --replace "PREFIX ?= /usr" ""
    sed -i -e 's/SED =.*/SED = sed/' Makefile
    sed -i -e 's/INSTALL =.*/INSTALL = install/' Makefile
  '';

  DESTDIR = placeholder "out";

  postConfigure = ''
    make configure
  '';

  buildPhase = ''
    make browserpass
  '';

  checkTarget = "test";

  installPhase = ''
    make install

    wrapProgram $out/bin/browserpass \
      --suffix PATH : ${lib.makeBinPath [ gnupg ]}

    # This path is used by our firefox wrapper for finding native messaging hosts
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    # Copy ff manifests rather than linking to allow link-farming to work recursively in dependants
    cp $out/lib/browserpass/hosts/firefox/*.json $out/lib/mozilla/native-messaging-hosts/
  '';

  passthru.tests.version = testers.testVersion {
    package = browserpass;
    command = "browserpass --version";
  };

  meta = with lib; {
    description = "Browserpass native client app";
    mainProgram = "browserpass";
    homepage = "https://github.com/browserpass/browserpass-native";
    license = licenses.isc;
    maintainers = with maintainers; [ rvolosatovs tennox ];
  };
}
