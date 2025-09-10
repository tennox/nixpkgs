{
  lib,
  stdenv,
  fetchFromGitHub,
  deno,
  installShellFiles,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "windmill-cli";
  version = "1.541.0";

  src = fetchFromGitHub {
    owner = "windmill-labs";
    repo = "windmill";
    rev = "v${version}";
    hash = "sha256-VPRYwdtUxl7g8DcHpbB4gtguoNF4V2lY2YjSXEosz3Y=";
  };

  sourceRoot = "${src.name}/cli";

  nativeBuildInputs = [
    deno
    installShellFiles
  ];

  postUnpack = ''
    # Copy pre-generated API client files
    cp -r ${./gen} $sourceRoot/gen
    cp -r ${./windmill-utils-internal/src/gen} $sourceRoot/windmill-utils-internal/src/gen
  '';

  buildPhase = ''
    runHook preBuild
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/windmill-cli $out/bin
    cp -r . $out/share/windmill-cli/
    
    # Create wrapper script that runs with Deno
    cat > $out/bin/wmill << EOF
    #!/usr/bin/env bash
    exec ${deno}/bin/deno run --allow-all ${placeholder "out"}/share/windmill-cli/src/main.ts "\$@"
    EOF
    chmod +x $out/bin/wmill
    
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A simple CLI allowing interactions with windmill from the command line";
    homepage = "https://windmill.dev";
    changelog = "https://github.com/windmill-labs/windmill/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wmill";
  };
}