{
  lib,
  stdenv,
  fetchzip,
  glib,
  gom,
  gsound,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-shell-extension-pano-gom";
  version = "24";

  src = fetchzip {
    url = "https://github.com/tennox/gnome-shell-pano/releases/download/v${finalAttrs.version}/pano@elhan.io.zip";
    hash = "sha256-185r73wpfb3h8z8181ivzi3a3f5ccpjmzzljm2gaccrql9swap3f";
    stripRoot = false;
  };

  nativeBuildInputs = [
    glib
  ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas --strict schemas
    runHook postBuild
  '';

  preInstall = ''
    # Patch the hardcoded Nix store path for gom
    substituteInPlace extension.js \
      --replace-fail "/nix/store/32mj4p8wzn03cx7zvaydz298zk0sc64p-gom-0.5.3/lib/girepository-1.0" "${gom}/lib/girepository-1.0"

    # Add gsound path if the extension uses it
    if grep -q "gi://GSound" extension.js; then
      substituteInPlace extension.js \
        --replace-fail "import GSound from 'gi://GSound'" \
        "imports.gi.GIRepository.Repository.prepend_search_path('${gsound}/lib/girepository-1.0'); const GSound = (await import('gi://GSound')).default"
    fi
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions
    cp -r -T . $out/share/gnome-shell/extensions/pano-gom@txlab.io
    runHook postInstall
  '';

  passthru = {
    extensionPortalSlug = "pano-gom";
    extensionUuid = "pano-gom@txlab.io";
  };

  meta = with lib; {
    description = "Next-gen Clipboard Manager for GNOME Shell (refactored with libgom)";
    homepage = "https://github.com/tennox/gnome-shell-pano";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
})
