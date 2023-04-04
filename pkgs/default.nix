final: prev: {
  sources = prev.callPackage (import ./_sources/generated.nix) { };

  carbon-now-nvim = final.callPackage ./carbon-now-nvim { };
  cargo-lints = final.callPackage ./cargo-lints { };
  cmp-fuzzy-path = final.callPackage ./cmp-fuzzy-path { };
  doing = final.callPackage ./doing { };
  fuzzy-nvim = final.callPackage ./fuzzy-nvim { };
  git-blame-nvim = final.callPackage ./git-blame-nvim { };
  key-menu-nvim = final.callPackage ./key-menu-nvim { };
  pest-vim = final.callPackage ./pest-vim { };
  rust-tools-nvim = final.callPackage ./rust-tools-nvim { };
  rust-vim = final.callPackage ./rust-vim { };
  telescope-file-browser-nvim = final.callPackage ./telescope-file-browser-nvim { };
}
