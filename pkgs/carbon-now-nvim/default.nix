{ sources
, pkgs
, vimUtils
}:

vimUtils.buildVimPluginFrom2Nix {
  pname = "carbon-now.nvim";
  inherit (sources.carbon-now-nvim) version src;
}
