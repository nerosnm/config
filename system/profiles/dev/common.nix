{ config
, pkgs
, ...
}:

# Development-specific packages and configuration.

{
  environment.systemPackages = with pkgs; [
    carapace
    # cargo-about
    # cargo-deny
    cargo-expand
    cargo-generate
    cargo-modules
    cargo-update
    convco
    gh
    jujutsu
    # go
    # gopls
    rustup
    tlaplus18
  ];
}
