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
  version = "25-alpha1";

  src = fetchzip {
    url = "https://github.com/tennox/gnome-shell-pano/releases/download/v${finalAttrs.version}/pano-gom@txlab.io.zip";
    hash = "sha256-OEujc8AuV+vRDQHIGPeGFalfIyeYFew0tYaP/Mb8FYw=";
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
    # Inject Gom typelib path at the beginning of extension.js
    # This ensures the typelib is found before any imports attempt to load it
    sed -i "1i imports.gi.GIRepository.Repository.prepend_search_path('${gom}/lib/girepository-1.0');" extension.js
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/pano-gom@txlab.io
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
