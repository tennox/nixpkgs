{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moxy";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "moxin-org";
    repo = "moly";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CxKCOFYTe8JPrsQhjRDi/HsKkTrN/EvGxycohUz2jk0=";
  };

  cargoHash = "sha256-1//+VVY52ViWopSaL4t2PkSZqwLDYAoU/don69Vy9To=";
  cargoBuildFlags = [
    "--package"
    "moly"
  ];

  meta = {
    description = "A Desktop + Cloud AI LLM GUI app in pure Rust ";
    homepage = "https://github.com/moxin-org/moly";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tennox ];
  };
})
