final: prev: {
  carbon-now-nvim = final.callPackage ./carbon-now-nvim.nix { };
  cmp-fuzzy-path = final.callPackage ./cmp-fuzzy-path.nix { };
  fuzzy-nvim = final.callPackage ./fuzzy-nvim.nix { };
  git-blame-nvim = final.callPackage ./git-blame-nvim.nix { };
  key-menu-nvim = final.callPackage ./key-menu-nvim.nix { };
  pest-vim = final.callPackage ./pest-vim.nix { };
  rust-tools-nvim = final.callPackage ./rust-tools-nvim.nix { };
  rust-vim = final.callPackage ./rust-vim.nix { };
  telescope-file-browser-nvim = final.callPackage ./telescope-file-browser-nvim.nix { };
  tla-nvim = final.callPackage ./tla-nvim.nix { };
}
