{ sources
, pkgs
, vimUtils
}:

vimUtils.buildVimPluginFrom2Nix {
  pname = "rust-tools.nvim";
  inherit (sources.rust-tools-nvim) version src;
}
