{ lib
, stdenv
, callPackage
, fetchFromGitHub
, rust-bin
, makeRustPlatform
, rustc
, darwin
, cmake
, libiconv
, useMimalloc ? false
, doCheck ? true
, sources
}:

let
  toolchain = rust-bin.stable.latest;
  rustPlatform = makeRustPlatform {
    inherit (toolchain) cargo;
    rustc = lib.attrsets.recursiveUpdate toolchain.rustc {
      meta.platforms = rustc.meta.platforms;
    };
  };
in
rustPlatform.buildRustPackage rec {
  pname = "rust-analyzer-unwrapped";

  inherit (sources.rust-analyzer) src version;
  cargoLock = sources.rust-analyzer.cargoLock."Cargo.lock";

  patches = [
    # Code format and git history check require more dependencies but don't really matter for packaging.
    # So just ignore them.
    ./ignore-git-and-rustfmt-tests.patch
  ];

  buildAndTestSubdir = "crates/rust-analyzer";

  nativeBuildInputs = lib.optional useMimalloc cmake;

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreServices
    libiconv
  ];

  buildFeatures = lib.optional useMimalloc "mimalloc";

  RUST_ANALYZER_REV = version;

  inherit doCheck;
  preCheck = lib.optionalString doCheck ''
    export RUST_SRC_PATH=${rustPlatform.rustLibSrc}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    versionOutput="$($out/bin/rust-analyzer --version)"
    echo "'rust-analyzer --version' returns: $versionOutput"
    [[ "$versionOutput" == "rust-analyzer ${version}" ]]
    runHook postInstallCheck
  '';

  passthru = {
    updateScript = ./update.sh;
    # FIXME: Pass overrided `rust-analyzer` once `buildRustPackage` also implements #119942
    tests.neovim-lsp = callPackage ./test-neovim-lsp.nix { };
  };

  meta = with lib; {
    description = "A modular compiler frontend for the Rust language";
    homepage = "https://rust-analyzer.github.io";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ oxalica ];
    mainProgram = "rust-analyzer";
  };
}
