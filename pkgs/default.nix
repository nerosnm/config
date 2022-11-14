final: prev: {
  # keep sources this first
  sources = prev.callPackage (import ./_sources/generated.nix) { };
  # then, call packages with `final.callPackage`
  carbon-now-nvim = final.callPackage ./carbon-now-nvim { };
  cargo-lints = final.callPackage ./cargo-lints { };
  cmp-fuzzy-path = final.callPackage ./cmp-fuzzy-path { };
  doing = final.callPackage ./doing { };
  discord-linux = final.callPackage ./discord-linux { };
  discord-ptb-linux = final.callPackage ./discord-ptb-linux { };
  fuzzy-nvim = final.callPackage ./fuzzy-nvim { };
  git-blame-nvim = final.callPackage ./git-blame-nvim { };
  key-menu-nvim = final.callPackage ./key-menu-nvim { };
  pest-vim = final.callPackage ./pest-vim { };
  telescope-file-browser-nvim = final.callPackage ./telescope-file-browser-nvim { };
  tree-sitter-rust = final.callPackage ./tree-sitter-rust { };
  rust-analyzer = final.callPackage ./rust-analyzer { };
  rust-vim = final.callPackage ./rust-vim { };
  vim-dogrun = final.callPackage ./vim-dogrun { };
}
