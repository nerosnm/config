{ self
, pkgs
, ...
}:

let
  rust = pkgs.rust-bin.stable.latest.minimal.override {
    extensions = [ "rust-docs" "rust-src" "clippy" ];
  };

  rustfmt = pkgs.rust-bin.nightly.latest.rustfmt;
in
{
  environment.systemPackages = with pkgs; [
    cargo-about
    cargo-deny
    cargo-expand
    cargo-geiger
    cargo-generate
    cargo-modules
    cargo-update
    cargo-watch

    clang_12
    rust
    rust-analyzer
    rustfmt

    go
    gopls

    ocamlPackages.ocaml-lsp
    ocamlformat
  ];
}
