{ sources, vimUtils }:

vimUtils.buildVimPlugin {
  pname = "fuzzy.nvim";
  inherit (sources.fuzzy-nvim) version src;
}
