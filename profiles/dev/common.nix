{ self
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    cargo-about
    cargo-deny
    cargo-expand
    cargo-geiger
    cargo-generate
    cargo-lints
    cargo-modules
    cargo-update
    cargo-watch

    clang_12
    rust-analyzer
    rustup

    go
    gopls

    gh

    ocamlPackages.ocaml-lsp
    ocamlformat
  ];
}
