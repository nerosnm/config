{ sources
, pkgs
, vimUtils
}:

vimUtils.buildVimPluginFrom2Nix {
  pname = "rust.vim";
  inherit (sources.rust-vim) version src;
}
