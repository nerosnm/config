{ config
, pkgs
, ...
}:

# Development-specific packages and configuration.

{
  environment.systemPackages = with pkgs; [
    cargo-about
    cargo-deny
    cargo-expand
    cargo-generate
    cargo-lints
    cargo-modules
    cargo-update
    cargo-watch
    convco
    gh
    # go
    # gopls
    rust-analyzer
    rustup
  ];
}
