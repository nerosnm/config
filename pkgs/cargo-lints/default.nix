{ sources, rustPlatform }:

rustPlatform.buildRustPackage rec {
  inherit (sources.cargo-lints) pname version src;
  cargoLock = sources.cargo-lints.cargoLock."Cargo.lock";
}
