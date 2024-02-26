{ config
, pkgs
, ...
}:

# Development-specific packages and configuration.

{
  environment.systemPackages = with pkgs; [
    # cargo-about
    # cargo-deny
    cargo-expand
    cargo-generate
    cargo-modules
    cargo-update
    convco
    gh
    # go
    # gopls
    rustup
    tlaplus18
  ];
}
